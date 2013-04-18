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

//#pragma mark - UIStoryboardSegue
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
//{
//    [super prepareForSegue:segue sender:sender];
//    
//    if ([segue.identifier isEqualToString:@"Show Photo Detail"]) {
//        [self setUpWithPhotos:[RecentPhotos allPhotos]];
//        [self.tableView moveRowAtIndexPath:[self.tableView indexPathForCell:sender] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    }
//}

@end
