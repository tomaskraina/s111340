//
//  PhotoListViewController.m
//  SPoT
//
//  Created by Tom K on 4/10/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "PhotoListViewController.h"
#import "FlickrFetcher.h"
#import "PhotoDetailViewController.h"

@interface PhotoListViewController ()
@property (strong, nonatomic) NSArray *photos; // of NSDictionary
@end

@implementation PhotoListViewController

- (void)setUpWithPhotos:(NSArray *)photos
{
    self.photos = photos;
    [self.tableView reloadData];
}

#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photo Detail"]) {
        PhotoDetailViewController *viewController = segue.destinationViewController;
        NSDictionary *photoInfo = self.photos[ [[self.tableView indexPathForSelectedRow] row] ];
        [viewController setUpWithPhotoInfo:photoInfo];
        viewController.title = photoInfo[FLICKR_PHOTO_TITLE];
        
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
    }
}

#pragma mark - UIViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.photos[indexPath.row][FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [self.photos[indexPath.row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}

#pragma mark - Helpers

- (id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] ||
        ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail = nil;
    return detail;
}

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
}

@end
