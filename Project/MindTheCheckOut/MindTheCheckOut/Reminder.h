//
//  Reminder.h
//  MindTheCheckOut
//
//  Created by Tom K on 5/25/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

extern NSString * const ReminderErrorDomain;

typedef NS_ENUM(NSUInteger, ReminderErrorCode) {
    ReminderErrorCodeAccessRestricted = 1,
    ReminderErrorCodeAccessDenied,
    ReminderErrorCodeSaveFailed,
    ReminderErrorCodeRemoveFailed,
    ReminderErrorCodeReasonUnknown
};

@interface Reminder : NSObject

@property (strong, nonatomic, readonly) EKReminder *reminder;

- (instancetype)initWithStructuredLocation:(EKStructuredLocation *)location
                                 proximity:(EKAlarmProximity)proximity
                                     title:(NSString *)title;

- (void)save:(void(^)())completitionHandler error:(void (^)(NSError *))errorBlock;;
- (void)cancel:(void (^)())completitionBlock error:(void (^)(NSError *))errorBlock;

+ (void)allReminders:(void (^)(NSArray *reminders))completitionBlock error:(void (^)(NSError *))errorBlock;
@end
