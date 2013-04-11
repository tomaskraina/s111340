//
//  RecentPhotos.m
//  SPoT
//
//  Created by Tom K on 4/11/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "RecentPhotos.h"
#import "FlickrFetcher.h"

#define MAX_COUNT 25
#define ALL_PHOTOS_KEY @"RecentPhotos"
#define PHOTO_INFO_KEY @"PhotoInfo"
#define LAST_VIEWED_KEY @"LastViewed"

@implementation RecentPhotos

+ (NSArray *)allPhotos
{
    NSMutableArray *allPhotos = [NSMutableArray array];
    NSArray *recentPhotos = [[NSUserDefaults standardUserDefaults] objectForKey:ALL_PHOTOS_KEY];
    
    NSArray *sortedPhotos = [recentPhotos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:LAST_VIEWED_KEY ascending:NO]]];
    
    for (NSDictionary *recentPhoto in sortedPhotos) {
        NSDictionary *photoInfo = recentPhoto[PHOTO_INFO_KEY];
        [allPhotos addObject:photoInfo];
    }
    
    return allPhotos;
}

+ (void)addPhoto:(NSDictionary *)photoInfo
{
    NSMutableArray *recentPhotos = [[[NSUserDefaults standardUserDefaults] objectForKey:ALL_PHOTOS_KEY] mutableCopy];
    if (!recentPhotos) {
        recentPhotos = [NSMutableArray array];
    }

    NSIndexSet *indexesToRemove = [recentPhotos indexesOfObjectsPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        return [obj[PHOTO_INFO_KEY][FLICKR_PHOTO_ID] isEqual:photoInfo[FLICKR_PHOTO_ID]];
    }];
    [recentPhotos removeObjectsAtIndexes:indexesToRemove];
    
    NSDictionary *recentPhoto = @{PHOTO_INFO_KEY : photoInfo, LAST_VIEWED_KEY : [NSDate date]};
    [recentPhotos addObject:recentPhoto];

    if ([recentPhotos count] > MAX_COUNT) {
        [recentPhotos removeObjectAtIndex:0];
    }

    [[NSUserDefaults standardUserDefaults] setObject:recentPhotos forKey:ALL_PHOTOS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
