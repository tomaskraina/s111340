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
#import "PinRadiusAnnotationView.h"

#define ORIGIN_LATITUDE 55.67609680
#define ORIGIN_LONGITUDE 12.56833710

@interface ReminderViewController () <MKMapViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) EKEventStore *eventStore;
@property (nonatomic, getter = isZoomed) BOOL zoomed;

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

- (void)setReminder:(Reminder *)reminder
{
    _reminder = reminder;
    
    if (!self.detailItem) {
        EKAlarm *alarm = [reminder.reminder.alarms lastObject];
        self.detailItem = @{
                            kStationName: alarm.structuredLocation.title,
                            kStationLatitude: [NSString stringWithFormat:@"%f", alarm.structuredLocation.geoLocation.coordinate.latitude],
                            kStationLongitude: [NSString stringWithFormat:@"%f",alarm.structuredLocation.geoLocation.coordinate.longitude]
                            };
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
    
    // Set up new reminder if not exists yet
    if (!self.reminder) {
        [self setUpReminder];
    }

    // Recreate alarm if activation radius changed
    if ([[[self.reminder.reminder.alarms lastObject] structuredLocation] radius] != [[NSUserDefaults standardUserDefaults] integerForKey:kActivationRadius]) {
        [self.reminder cancel:^{
            [self setUpReminder];
        } error:NULL];
    }
    
    [self zoomToSelectedStation];
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

    self.isZoomed ? [self zoomOut] : [self zoomIn];
}

- (IBAction)cancelReminder:(id)sender
{
    [self.reminder cancel:NULL error:^(NSError *error) {
        NSLog(@"Can't cancel reminder: %@", error);
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Reminder methods

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

- (void)zoomIn
{
    [self.mapView setRegion:[self zoomedCoordinateRegion] animated:YES];
    self.zoomed = YES;
}

- (void)zoomOut
{
    [self.mapView setRegion:[self defaultCoordinateRegion] animated:YES];
    self.zoomed = NO;
}

- (void)zoomToSelectedStation
{
    CLLocationCoordinate2D coordinates = [[self locationFromStation:self.detailItem] coordinate];
    
    [self.mapView setCenterCoordinate:coordinates animated:YES];
    [self zoomIn];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.detailItem];
    
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.mapView selectAnnotation:self.detailItem animated:YES];
    });
}

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
    PinRadiusAnnotationView *annotationView = (PinRadiusAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (annotationView == nil) {
        annotationView = [[PinRadiusAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
    }
    
    // remove and add overlay in case the radius has changed
    [self.mapView removeOverlay:annotationView.radiusOverlay];
    id<MKOverlay> overlay = [self circleOverlayForAnnotation:annotation];
    annotationView.radiusOverlay = overlay;
    [self.mapView addOverlay:overlay];
    
    return annotationView;
}

- (MKCircle *)circleOverlayForAnnotation:(id<MKAnnotation>)annotation
{    
    double radius = (double)[[NSUserDefaults standardUserDefaults] integerForKey:kActivationRadius];
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:radius];
    return circle;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	if([overlay isKindOfClass:[MKCircle class]]) {
		// Create the view for the radius overlay.
		MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
		circleView.strokeColor = [UIColor redColor];
		circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:.4];
		
		return circleView;
	}
	
	return nil;
}

@end
