//
//  TagsViewController.m
//  SPoT
//
//  Created by Tom K on 4/10/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "TagsViewController.h"
#import "FlickrFetcher.h"
#import "PhotoListViewController.h"
#import "PhotoDetailViewController.h"

@interface TagsViewController ()
@property (strong, nonatomic) NSArray *tags; // of NSString
@property (strong, nonatomic) NSDictionary *tagsPhotosDictionary; // key NSString, object NSMutableSet
@property (nonatomic, getter = isLoading) BOOL loading;
@end

@implementation TagsViewController

+ (NSArray *)excludedTags
{
    static NSArray *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = @[@"cs193pspot", @"portrait", @"landscape"];
    });

    return array;
}

#pragma mark - Properties

- (void)setLoading:(BOOL)loading
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:loading];
    if (loading) {
        [self.refreshControl beginRefreshing];
    }
    else {
        [self.refreshControl endRefreshing];
    }
}

- (BOOL)isLoading
{
    return [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible];
}

#pragma mark - IBActions

- (IBAction)refresh:(id)sender {
    [self reloadTags];
}


#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photos"]) {
        PhotoListViewController *viewController = segue.destinationViewController;
        NSString *tag = self.tags[ [[self.tableView indexPathForSelectedRow] row] ];
        NSArray *photosSortedByName = [[self.tagsPhotosDictionary[tag] allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:FLICKR_PHOTO_TITLE ascending:YES]]];
        [viewController setUpWithPhotos:photosSortedByName];
        viewController.title = [tag capitalizedString];
    }
}

#pragma mark - UIViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self reloadTags];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Downloading

- (void)reloadTags
{
    self.loading = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("table view loading", NULL);
    dispatch_async(queue, ^{
        NSArray *allPhotos = [FlickrFetcher stanfordPhotos];
        self.tagsPhotosDictionary = [self tagsPhotosDictionaryFromPhotos:allPhotos];
        self.tags = [[self.tagsPhotosDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loading = NO;
            [self.tableView reloadData];
        });
    });

}

- (NSDictionary *)tagsPhotosDictionaryFromPhotos:(NSArray *)photos
{
    NSMutableDictionary *tagsPhotos = [NSMutableDictionary dictionary];
    for (NSDictionary *photoInfo in photos) {
        
        NSArray *filteredPhotoTags = [self filteredTagsInPhoto:photoInfo];
        
        for (id tag in filteredPhotoTags) {
            NSMutableSet *photoSet = tagsPhotos[tag];
            if (!photoSet) {
                photoSet = [NSMutableSet set];
            }
            
            [photoSet addObject:photoInfo];
            tagsPhotos[tag] = photoSet;
        }
    }
    
    return tagsPhotos;
}

- (NSArray *)filteredTagsInPhoto:(NSDictionary *)flickrPhoto
{
    NSArray *photoTags = [flickrPhoto[FLICKR_TAGS] componentsSeparatedByString:@" "];
    NSArray *filteredPhotoTags = [photoTags filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![[TagsViewController excludedTags] containsObject:evaluatedObject];
    }]];
    
    return filteredPhotoTags;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TagCell = @"Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TagCell];
    
    NSString *tag = self.tags[indexPath.row];
    cell.textLabel.text = [tag capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.tagsPhotosDictionary[tag] count]];
    
    return cell;
}

@end
