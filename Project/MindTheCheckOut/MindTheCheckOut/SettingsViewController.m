//
//  SettingsViewController.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/23/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constancts.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *activationRadiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoomRadiusLabel;
@property (weak, nonatomic) IBOutlet UIStepper *activationRadiusStepper;
@property (weak, nonatomic) IBOutlet UIStepper *zoomRadiusStepper;
@end

@implementation SettingsViewController

#pragma mark - Properties

- (void)setZoomRadiusStepper:(UIStepper *)radiusStepper
{
    _zoomRadiusStepper = radiusStepper;
    _zoomRadiusStepper.minimumValue = 250;
    _zoomRadiusStepper.maximumValue = 50*1000;
    _zoomRadiusStepper.stepValue = 250;
    
    _zoomRadiusStepper.value = [[NSUserDefaults standardUserDefaults] doubleForKey:kZoomRadius];
}

- (void)setActivationRadiusStepper:(UIStepper *)radiusStepper
{
    _activationRadiusStepper = radiusStepper;
    _activationRadiusStepper.minimumValue = 50;
    _activationRadiusStepper.maximumValue = 1000;
    _activationRadiusStepper.stepValue = 25;
    
    _activationRadiusStepper.value = [[NSUserDefaults standardUserDefaults] integerForKey:kActivationRadius];
}

- (void)setZoomRadiusLabelValue:(double)radius
{
    self.zoomRadiusLabel.text = [NSString stringWithFormat:@"%.2fkm", (double)radius/1000.0];
}

- (void)setActivationRadiusLabelValue:(NSInteger)radius
{
    self.activationRadiusLabel.text = [NSString stringWithFormat:@"%um", radius];
}

#pragma mark - UIViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setZoomRadiusLabelValue:self.zoomRadiusStepper.value];
    [self setActivationRadiusLabelValue:(NSInteger)self.activationRadiusStepper.value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)setZoomRadius:(UIStepper *)sender
{
    [self setZoomRadiusLabelValue:sender.value];
    [[NSUserDefaults standardUserDefaults] setDouble:sender.value forKey:kZoomRadius];
}

- (IBAction)setActivationRadius:(UIStepper *)sender
{
    [self setActivationRadiusLabelValue:(NSInteger)sender.value];
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)sender.value forKey:kActivationRadius];
}

- (IBAction)done:(id)sender
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
