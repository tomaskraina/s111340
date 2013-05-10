//
//  ReminderViewController.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/7/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "ReminderViewController.h"
#import "StationFetcher.h"
#import <EventKit/EventKit.h>

@interface ReminderViewController ()
@property (strong, nonatomic) EKEventStore *eventStore;
- (void)configureView;
@end

@implementation ReminderViewController

#pragma mark - Properties

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (EKEventStore *)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    
    return _eventStore;
}

#pragma mark - UIViewController life cycle

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        NSString *baseText = NSLocalizedStringFromTable(@"Description - Text", @"ReminderViewController", @"Must containt %@ for station's name");
        self.detailDescriptionLabel.text = [NSString stringWithFormat:baseText, self.detailItem[kStationName]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setUpReminder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_setUpReminder
{
    EKStructuredLocation *structuredLocation = [EKStructuredLocation locationWithTitle:self.detailItem[kStationName]];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.detailItem[kStationLatitude] doubleValue] longitude:[self.detailItem[kStationLongitude] doubleValue]];
    structuredLocation.geoLocation = location;
    structuredLocation.radius = 150; // metres
    
    EKAlarm *alarm = [[EKAlarm alloc] init];
    alarm.proximity = EKAlarmProximityEnter;
    alarm.structuredLocation = structuredLocation;
    
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
    reminder.calendar = [self.eventStore defaultCalendarForNewReminders];
    NSString *baseText = NSLocalizedStringFromTable(@"Reminder - Title", @"ReminderViewController", @"Must contain %@ for reminder's name");
    reminder.title = [NSString stringWithFormat:baseText, self.detailItem[kStationName]];
    [reminder addAlarm:alarm];
    
    NSError *error;
    if (![self.eventStore saveReminder:reminder commit:YES error:&error]) {
        NSLog(@"%@", error);
    }

    
}

- (void)setUpReminder
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        // data accessible
        [self _setUpReminder];
    }];
    
}

@end
