//
//  GoogleStationFetcher.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/23/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "GoogleStationFetcher.h"
#import "APIkeys.h"
#import <AFNetworking/AFNetworking.h>

NSString * const GoogleStatusOK = @"OK";
NSString * const GoogleStatusNoResult = @"ZERO_RESULTS";
NSString * const GoogleStatusOverLimit = @"OVER_QUERY_LIMIT";
NSString * const GoogleStatusRequestDenied = @"REQUEST_DENIED";

NSString * const GoogleQueryFormat = @"%@ st Denmark";

@interface GoogleStationFetcher ()
@end

@implementation GoogleStationFetcher

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
                                    kStationName: [place valueForKeyPath:@"name"],
                                    kStationLatitude: [place valueForKeyPath:@"geometry.location.lat"],
                                    kStationLongitude: [place valueForKeyPath:@"geometry.location.lng"],
                                    kStationTypes: [place valueForKeyPath:@"types"],
                                    kStationID: [place valueForKeyPath:@"id"]
                                    };
        [places addObject:placeInfo];
    }
    
    return [places copy];
}

- (NSError *)produceErrorFromGoogleJSON:(id)JSON
{
    NSError *error;
    NSString *status = [JSON valueForKey:@"status"];
    if ([status isEqualToString:GoogleStatusOverLimit]) {
        error = [NSError errorWithDomain:StationFetcherErrorDomain code:StationFetcherErrorCodeOverLimit userInfo:@{NSLocalizedFailureReasonErrorKey: status}];
    }
    else if ([status isEqualToString:GoogleStatusRequestDenied]) {
        error = [NSError errorWithDomain:StationFetcherErrorDomain code:StationFetcherErrorCodeRequestDenied userInfo:@{NSLocalizedFailureReasonErrorKey: status}];
    }
    
    return error;
}

- (void)findByName:(NSString *)searchName completed:(void (^)(NSArray *stations))completedBlock error:(void (^)(NSError *error))errorBlock
{
    if ([searchName length] < 3) {
        completedBlock(nil);
        return;
    }
    
    NSURL *baseUrl = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/textsearch/"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    NSDictionary *params = @{
                             @"query": [NSString stringWithFormat:GoogleQueryFormat, searchName],
                             @"key": GOOGLE_PLACES_API_KEY,
                             @"sensor": @"false",
                             @"types": @"bus_station|subway_station|train_station"
                             };
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:@"json" parameters:params];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self logResponse:JSON query:params[@"query"]];
        
        NSString *status = [JSON valueForKeyPath:@"status"];
        if ([status isEqualToString:GoogleStatusOK] || [status isEqualToString:GoogleStatusNoResult]) {
            // execute completition block
            completedBlock([self produceArrayStationInfoFromGoogleJSON:JSON]);
        }
        else {
            errorBlock([self produceErrorFromGoogleJSON:JSON]);
        }
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
        NSLog(@"Returned JSON: %@", JSON);
        
        errorBlock(error);
    }];
    
    [operation start];
    
}

@end
