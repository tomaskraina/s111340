//
//  StationFetcher.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/10/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "StationFetcher.h"
#import "AFNetworking.h"
#import "APIkeys.h"

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

- (void)logResponse:(id)JSON query:(NSString *)query
{
    NSLog(@"Searching for: '%@', results: %d, status: %@ ", query, [[JSON valueForKey:@"results"] count], [JSON valueForKey:@"status"]);
}

- (NSArray *)produceArrayStationInfoFromGoogleJSON:(id)JSON
{
    NSMutableArray *places = [NSMutableArray array];
    for (id place in [JSON valueForKeyPath:@"results"]) {
        NSDictionary *placeInfo = @{
                                    kStationName: place[@"name"],
                                    kStationLatitude: place[@"geometry.location.lat"],
                                    kStationLongitude: place[@"geometry.location.lng"]
                                    };
        [places addObject:placeInfo];
    }

    return [places copy];
}

- (void)findByName:(NSString *)searchName completed:(void (^)(NSArray *stations))block
{
    if ([searchName length] < 3) {
        block(nil);
        return;
    }
    
    dispatch_queue_t q = dispatch_queue_create("search queue", NULL);
    dispatch_async(q, ^{
        
        NSURL *baseUrl = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/textsearch/"];
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
        NSDictionary *params = @{
                                 @"query": [NSString stringWithFormat:@"%@ st, Denmark", searchName],
                                 @"key": GOOGLE_PLACES_API_KEY,
                                 @"sensor": @"false",
                                 @"types": @"bus_station|subway_station|train_station"
                                 };
        NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:@"json" parameters:params];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            [self logResponse:JSON query:params[@"query"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // execute completition block
                block([self produceArrayStationInfoFromGoogleJSON:JSON]);
            });
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"%@", error);
        }];
        
        [operation start];
        
    });
}

@end
