//
//  SettingsViewController.m
//  Matchismo
//
//  Created by Tom on 10.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "SettingsViewController.h"
#import "GameResult.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (IBAction)eraseGameHistory:(id)sender
{
    [GameResult eraseGameResults];
}

@end
