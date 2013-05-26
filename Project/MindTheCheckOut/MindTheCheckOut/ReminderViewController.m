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
#import <MapKit/MapKit.h>
#import "NSDictionary+MKAnnotation.h"
#import "Constancts.h"
#import "Reminder.h"

#define ORIGIN_LATITUDE 55.67609680
#define ORIGIN_LONGITUDE 12.56833710

@interface ReminderViewController () <MKMapViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) EKEventStore *eventStore;
@property (nonatomic, getter = isZoomed) BOOL zoomed;
@property (strong, nonatomic) Reminder *reminder;

// Labels
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;

// Buttons
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;

// Other views
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) MKAnnotationView *annotationView;

@end

@implementation ReminderViewController

#pragma mark - Properties

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
        
        NSLog(@"Selected station: %@", _detailItem);
    }
}



- (void)setMapView:(MKMapView *)mapView
{
    if (_mapView != mapView) {
        _mapView = mapView;
        
        _mapView.mapType = MKMapTypeHybrid;
        _mapView.zoomEnabled = YES;
        _mapView.scrollEnabled = YES;
        
        _mapView.showsUserLocation = YES;
        _mapView.region = [self defaultCoordinateRegion];
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
        self.stationLabel.text = [self.detailItem[kStationName] uppercaseString];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Load localized texts
    self.titleLabel.text = NSLocalizedStringFromTable(@"Title - Label", @"ReminderViewController", @"You have selected");
    self.descriptionLabel.text = NSLocalizedStringFromTable(@"Description - Label", @"ReminderViewController", @"As The Location To Remind You To Check Out At");
    self.notesLabel.text = NSLocalizedStringFromTable(@"Notes - Label", @"ReminderViewController", @"You will be reminded when you arrive there. Feel free to close this app or just lock your screen.");
    [self.cancelButton setTitle:NSLocalizedStringFromTable(@"Cancel Button - Title", @"ReminderViewController", @"Cancel Reminder") forState:UIControlStateNormal];
    
    self.mapButton.hidden = YES;
    
    [self configureView];
    
//    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self isMovingToParentViewController] || [self isBeingPresented]) {
        [self setUpReminder];
        
        [self.mapView setCenterCoordinate:[[self locationFromStation:self.detailItem] coordinate] animated:YES];
        [self toggleZoom:self];
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotation:self.detailItem];
        
        double delayInSeconds = .5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.mapView selectAnnotation:self.detailItem animated:YES];
        });
    }
    else {
        // TODO: recreate alarm if activation radius changed
        self.zoomed = NO; // hack...
        [self toggleZoom:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
//        [self.reminder cancel:NULL error:^(NSError *error) {
//            NSLog(@"Can't cancel reminder: %@", error);
//        }];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)toggleZoom:(id)sender
{
    double zoomRadius = [[NSUserDefaults standardUserDefaults] doubleForKey:kZoomRadius];
    NSLog(@"Toggle zoom: %@", self.isZoomed ? @"out" : [NSString stringWithFormat:@"in %.0fm", zoomRadius]);
    
    [self.mapView setRegion:self.isZoomed ? [self defaultCoordinateRegion] : [self zoomedCoordinateRegion] animated:YES];
    
    self.zoomed = !self.isZoomed;
}


- (IBAction)cancelReminder:(id)sender
{
    [self.reminder cancel:NULL error:^(NSError *error) {
        NSLog(@"Can't cancel reminder: %@", error);
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Reminder methods

//- (void)_setUpReminder
//{
//    EKStructuredLocation *structuredLocation = [EKStructuredLocation locationWithTitle:self.detailItem[kStationName]];
//    CLLocation *location = [self locationFromStation:self.detailItem];
//    structuredLocation.geoLocation = location;
//    structuredLocation.radius = [[NSUserDefaults standardUserDefaults] integerForKey:kActivationRadius]; // metres
//    
//    EKAlarm *alarm = [[EKAlarm alloc] init];
//    alarm.proximity = EKAlarmProximityEnter;
//    alarm.structuredLocation = structuredLocation;
//    
//    EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
//    reminder.calendar = [self.eventStore defaultCalendarForNewReminders];
//    NSString *baseText = NSLocalizedStringFromTable(@"Reminder - Title", @"ReminderViewController", @"Must contain %@ for reminder's name");
//    reminder.title = [NSString stringWithFormat:baseText, self.detailItem[kStationName]];
//    [reminder addAlarm:alarm];
//    
//    NSError *error;
//    if (![self.eventStore saveReminder:reminder commit:YES error:&error]) {
//        NSLog(@"%@", error);
//    }
//    else {
//        self.reminder = reminder;
//        NSLog(@"Reminder has been set up: %@", reminder);
//    }
//}

- (void)setUpReminder
{
    EKStructuredLocation *structuredLocation = [EKStructuredLocation locationWithTitle:self.detailItem[kStationName]];
    CLLocation *location = [self locationFromStation:self.detailItem];
    structuredLocation.geoLocation = location;
    structuredLocation.radius = [[NSUserDefaults standardUserDefaults] integerForKey:kActivationRadius]; // metres
    
    NSString *baseText = NSLocalizedStringFromTable(@"Reminder - Title", @"ReminderViewController", @"Must contain %@ for reminder's name");
    NSString *title = [NSString stringWithFormat:baseText, self.detailItem[kStationName]];
    Reminder *reminder = [[Reminder alloc] initWithStructuredLocation:structuredLocation proximity:EKAlarmProximityEnter title:title];
    
    [reminder save:^{
        NSLog(@"Reminder saved!");
        self.reminder = reminder;
    } error:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedFailureReason] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - UIAlertViewDelegate

// Can't save reminder alert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Convinience methods

- (MKCoordinateRegion)zoomedCoordinateRegion
{
    double zoomRadius = [[NSUserDefaults standardUserDefaults] doubleForKey:kZoomRadius];
    return MKCoordinateRegionMakeWithDistance([[self locationFromStation:self.detailItem] coordinate], zoomRadius, zoomRadius);
}

- (MKCoordinateRegion)defaultCoordinateRegion
{
    return MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(ORIGIN_LATITUDE, ORIGIN_LONGITUDE), 30*1000, 100*1000);
}

- (CLLocation *)locationFromStation:(NSDictionary *)station
{
    return [[CLLocation alloc] initWithLatitude:[station[kStationLatitude] doubleValue] longitude:[station[kStationLongitude] doubleValue]];
}

#pragma mark - UIMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation) return nil;
    
    static NSString *AnnotationIdentifier = @"Pin";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
    }
    
    return annotationView;
}

@end
