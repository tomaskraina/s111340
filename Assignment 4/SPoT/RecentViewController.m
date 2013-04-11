//
//  RecentViewController.m
//  SPoT
//
//  Created by Tom K on 4/10/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "RecentViewController.h"
#import "RecentPhotos.h"

@interface RecentViewController ()

@end

@implementation RecentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self setUpWithPhotos:[RecentPhotos allPhotos]];
}

@end
