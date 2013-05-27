//
//  Reminder.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/25/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "Reminder.h"

NSString * const ReminderErrorDomain = @"com.tomkraina.MindTheCheckout.Reminder";
NSString * const kReminders = @"Reminders";

@interface Reminder ()
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) EKAlarm *alarm;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic, readwrite) EKReminder *reminder;
@end

@implementation Reminder

#pragma mark - Properties

+ (EKEventStore *)eventStore
{
    static EKEventStore *eventStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventStore = [[EKEventStore alloc] init];
    });
    
    return eventStore;
}

- (EKEventStore *)eventStore
{
    if (!_eventStore) {
        _eventStore = [[self class] eventStore];
    }
    
    return _eventStore;
}


- (EKReminder *)reminder
{
    if (!_reminder) {
        EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
        reminder.calendar = [self.eventStore defaultCalendarForNewReminders];
        reminder.title = self.title;
        [reminder addAlarm:self.alarm];
        
        _reminder = reminder;
    }
    return _reminder;
}

#pragma mark - Public methods

- (instancetype)initWithReminder:(EKReminder *)reminder
{
    self = [super init];
    if (self) {
        _reminder = reminder;
        _alarm = [[reminder alarms] lastObject];
        _title = [reminder title];
    }
    
    return self;
}

- (instancetype)initWithStructuredLocation:(EKStructuredLocation *)location
                                 proximity:(EKAlarmProximity)proximity
                                     title:(NSString *)title
{
    self = [super init];
    if (self) {
        _alarm = [[self class] alarmWithStructuredLocation:location proximity:proximity];
        _title = title;
    }
    
    return self;
}

- (void)save:(void (^)())completitionBlock error:(void (^)(NSError *))errorBlock
{
    [[self class] authorize:^(BOOL granted, NSError *error) {
        if (granted) {
            EKReminder *reminder = self.reminder;
            NSError *savingError;
            if (![self.eventStore saveReminder:reminder commit:YES error:&savingError]) {
                NSLog(@"Save reminder failed: %@", savingError);
                errorBlock([[self class] errorForCode:ReminderErrorCodeSaveFailed underlyingError:savingError]);
            }
            else {
                NSLog(@"Reminder has been set up: %@", reminder);
                [[self class] saveReminderIndentifier:self.reminder.calendarItemIdentifier];
                completitionBlock();
            }
        }
        else {
            errorBlock(error);
        }
    }];
}

- (void)cancel:(void (^)())completitionBlock error:(void (^)(NSError *))errorBlock
{
    [[self class] authorize:^(BOOL granted, NSError *error) {
        if (granted) {
            NSError *cancellingError;
            if (![self.eventStore removeReminder:self.reminder commit:YES error:&cancellingError]) {
                NSLog(@"Remove reminder failed: %@", cancellingError);
                errorBlock([[self class] errorForCode:ReminderErrorCodeRemoveFailed underlyingError:cancellingError]);
            }
            else {
                NSLog(@"Reminder has been removed: %@", self.reminder);
                [[self class] removeReminderIdentifier:self.reminder.calendarItemIdentifier];
                if (completitionBlock) {
                    completitionBlock();
                }
            }
        }
        else {
            errorBlock(error);
        }
    }];
}

+ (void)allReminders:(void (^)(NSArray *reminders))completitionBlock error:(void (^)(NSError *))errorBlock
{
    [[self class] authorize:^(BOOL granted, NSError *error) {
        if (granted) {
            EKEventStore *eventStore = [[self class] eventStore];
            NSMutableArray *reminders = [NSMutableArray array];
            for (NSString *identifier in [[self class] allRemindersIdentifiers]) {
                EKCalendarItem *reminder = [eventStore calendarItemWithIdentifier:identifier];
                if (reminder && [reminder isKindOfClass:[EKReminder class]]) {
                    [reminders addObject:[[Reminder alloc] initWithReminder:(EKReminder *)reminder]];
                }
            }
            completitionBlock(reminders);
        }
        else {
            errorBlock(error);
        }
    }];
}

#pragma mark - Private methods

+ (NSMutableArray *)allRemindersIdentifiers
{
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSMutableArray *reminders = [[storage objectForKey:kReminders] mutableCopy];
    if (!reminders) {
        reminders = [NSMutableArray array];
    }
    
    return reminders;
}

+ (void)saveReminderIndentifier:(NSString *)identifier
{
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSMutableArray *reminders = [[self class] allRemindersIdentifiers];
    
    [reminders removeObject:identifier];
    [reminders insertObject:identifier atIndex:0];
    
    [storage setObject:reminders forKey:kReminders];
    [storage synchronize];
}

+ (void)removeReminderIdentifier:(NSString *)identifier
{
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSMutableArray *reminders = [[self class] allRemindersIdentifiers];
    
    [reminders removeObject:identifier];
    
    [storage setObject:reminders forKey:kReminders];
    [storage synchronize];
}

+ (void)authorize:(void (^)(BOOL granted, NSError *error))completitionBlock
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (status) {
        case EKAuthorizationStatusAuthorized:
            completitionBlock(YES, nil);
            break;
        case EKAuthorizationStatusNotDetermined:
            [[self class] requestAccess:completitionBlock];
            break;
        default: // Access denied
            completitionBlock(NO, [[self class] errorForAuthorizationStatus:status]);
            break;
    }
}

+ (void)requestAccess:(void (^)(BOOL granted, NSError *error))completitionBlock
{
    [[[self class] eventStore] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        completitionBlock(granted, error);
    }];
}

+ (EKAlarm *)alarmWithStructuredLocation:(EKStructuredLocation *)location proximity:(EKAlarmProximity)proximity;
{
    EKAlarm *alarm = [[EKAlarm alloc] init];
    alarm.structuredLocation = location;
    alarm.proximity = proximity;
    
    return alarm;
}

#pragma mark - Error factory methods

+ (NSError *)errorForCode:(ReminderErrorCode)code underlyingError:(NSError *)underlyingError
{
    NSString *decription, *failureReason, *recoverySuggestion;
    switch (code) {
        case ReminderErrorCodeSaveFailed:
            decription = NSLocalizedStringFromTable(@"Saving reminder failed", @"Reminder", nil);
            recoverySuggestion = NSLocalizedStringFromTable(@"Try to adding the reminder again.", @"Reminder", nil);
            break;
        case ReminderErrorCodeRemoveFailed:
            decription = NSLocalizedStringFromTable(@"Removing reminder failed", @"Reminder", nil);
            recoverySuggestion = NSLocalizedStringFromTable(@"Try to canceling the reminder again.", @"Reminder", nil);
            break;
        case ReminderErrorCodeAccessRestricted:
        case ReminderErrorCodeAccessDenied:
            decription = NSLocalizedStringFromTable(@"Access to Reminders denied. This application is not allowed to access existing reminders or create any new ones.", @"Reminder", nil);
            failureReason = NSLocalizedStringFromTable(@"The application can't use Reminders because the access has been denied.", @"Reminder", nil);
            recoverySuggestion = NSLocalizedStringFromTable(@"Grand access to Reminders in Settings/Privacy/Remindes", @"Reminder", nil);
            break;
        default:
            break;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (decription) [userInfo setObject:decription forKey:NSLocalizedDescriptionKey];
    if (failureReason) [userInfo setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
    if (recoverySuggestion) [userInfo setObject:recoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
    if (underlyingError) [userInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
    
    NSError *error = [NSError errorWithDomain:ReminderErrorDomain code:code userInfo:userInfo];
    return error;
}

+ (NSError *)errorForAuthorizationStatus:(EKAuthorizationStatus)authorizationStatus
{
    ReminderErrorCode code;
    switch (authorizationStatus) {
        case EKAuthorizationStatusDenied:
            code = ReminderErrorCodeAccessDenied;
            break;
        case EKAuthorizationStatusRestricted:
            code = ReminderErrorCodeAccessRestricted;
            break;
        default:
            code = ReminderErrorCodeReasonUnknown;
            break;
    }
    
    return [[self class] errorForCode:code underlyingError:nil];
}

@end
