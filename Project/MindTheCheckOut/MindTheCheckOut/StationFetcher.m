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

#define SEARCH_OPTIONS (NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch | NSAnchoredSearch)

@interface StationFetcher ()
@property (strong, nonatomic) NSArray *downloadedStations;
@end

@implementation StationFetcher

- (NSArray *)downloadedStations
{
    if (!_downloadedStations) {
        NSMutableArray *temp = [NSMutableArray array];
        [temp addObject:@{
         @"name": @"Frederiskberg st. (Metro)",
         @"latitude": @"55.6812030",
         @"longitude": @"12.5339930"
         }];
        [temp addObject:@{
         @"name": @"Lyngby st.",
         @"latitude": @"55.7680839",
         @"longitude": @"12.5031010"
         }];
        [temp addObject:@{
         @"name": @"Nørreport st.",
         @"latitude": @"55.6830530",
         @"longitude": @"12.5713060"
         }];
        [temp addObject:@{
         @"name": @"Ørestad st. (Metro)",
         @"latitude": @"55.6290550",
         @"longitude": @"12.5793890"
         }];
        
        _downloadedStations = [temp copy];
    }
    
    return  _downloadedStations;
}

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

#pragma mark - searching methods

- (void)findByName:(NSString *)searchName completed:(void (^)(NSArray *stations))block
{
    dispatch_queue_t q = dispatch_queue_create("search queue", NULL);
    dispatch_async(q, ^{
        
        NSArray *filteredStations = [self.downloadedStations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"name"] rangeOfString:searchName options:SEARCH_OPTIONS].location != NSNotFound;
        }]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // execute completition block
            block(filteredStations);
        });
        
    });
}

@end
