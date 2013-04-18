//
//  MasterViewController.m
//  
//
//  Created by Tom K on 4/19/13.
//
//

#import "MasterViewController.h"
#import "PhotoDetailViewController.h"

@implementation MasterViewController

#pragma mark - UIViewController life cycle

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = NSLocalizedString(@"Photos", @"UIBarButtonItem title - List of photos");
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    [detailViewController setSplitViewBarButtonItem:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    [detailViewController setSplitViewBarButtonItem:nil];
}

@end
