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

@interface TagsViewController ()
@property (strong, nonatomic) NSArray *tags; // of NSString
@property (strong, nonatomic) NSDictionary *tagsPhotosDictionary; // key NSString, object NSMutableSet
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

- (NSArray *)tags
{
    if (!_tags) {
        NSArray *allPhotos = [FlickrFetcher stanfordPhotos];
        
        NSMutableSet *tags = [NSMutableSet set];
        NSMutableDictionary *tagsPhotos = [NSMutableDictionary dictionary];
        for (NSDictionary *photoInfo in allPhotos) {
            NSArray *photoTags = [photoInfo[FLICKR_TAGS] componentsSeparatedByString:@" "];
            NSArray *filteredPhotoTags = [photoTags filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return ![[TagsViewController excludedTags] containsObject:evaluatedObject];
            }]];

            [tags addObjectsFromArray:filteredPhotoTags];
            for (id tag in filteredPhotoTags) {
                NSMutableSet *photos = tagsPhotos[tag];
                if (!photos) {
                    photos = [NSMutableSet set];
                }
                
                [photos addObject:photoInfo];
                tagsPhotos[tag] = photos;
            }
        }
        
        self.tagsPhotosDictionary = tagsPhotos;
        _tags = [tags allObjects];
    }
    
    return _tags;
}

#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photos"]) {
        PhotoListViewController *viewController = segue.destinationViewController;
        NSString *tag = self.tags[ [[self.tableView indexPathForSelectedRow] row] ];
        [viewController setUpWithPhotos:[self.tagsPhotosDictionary[tag] allObjects]];
    }
}

#pragma mark - UIViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
