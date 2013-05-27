//
//  StationFetcher.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/10/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "StationFetcher.h"

NSString * const kStationName = @"name";
NSString * const kStationLatitude = @"latitude";
NSString * const kStationLongitude = @"longitude";
NSString * const kStationTypes = @"types";
NSString * const kStationID = @"id";

NSString * const StationFetcherErrorDomain = @"com.tomkraina.MindTheCheckout.StationFetcher";


#define SEARCH_OPTIONS (NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch | NSAnchoredSearch)

@interface StationFetcher ()
@end

@implementation StationFetcher


#pragma mark - Init methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Do some stuff
    }
    
    return self;
}

+ (instancetype)defaultFetcher
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)findByName:(NSString *)searchName completed:(void (^)(NSArray *stations))block error:(void (^)(NSError *error))error
{
    
}

@end
