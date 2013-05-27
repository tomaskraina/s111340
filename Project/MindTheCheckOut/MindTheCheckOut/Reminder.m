//
//  Reminder.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/25/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "Reminder.h"

NSString * const ReminderErrorDomain = @"Reminder";
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
                NSLog(@"%@", savingError);
                errorBlock(savingError);
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
                NSLog(@"%@", cancellingError);
                errorBlock(cancellingError);
            }
            else {
                // TODO: delete ID in persistent storage
                NSLog(@"Reminder has been removed: %@", self.reminder);
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

+ (NSArray *)allRemindersIdentifiers
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kReminders];
}

+ (void)saveReminderIndentifier:(NSString *)identifier
{
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSMutableArray *reminders = [[storage objectForKey:kReminders] mutableCopy];
    if (!reminders) {
        reminders = [NSMutableArray array];
    }
    
    [reminders insertObject:identifier atIndex:0];
    
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

+ (NSError *)errorForAuthorizationStatus:(EKAuthorizationStatus)authorizationStatus
{
    NSError *error = [NSError errorWithDomain:ReminderErrorDomain code:authorizationStatus userInfo:nil];
    // TODO: failure reason
    return error;
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

@end
