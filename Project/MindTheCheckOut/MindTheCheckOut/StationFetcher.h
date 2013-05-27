//
//  StationFetcher.h
//  MindTheCheckOut
//
//  Created by Tom K on 5/10/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kStationName;
extern NSString * const kStationLatitude;
extern NSString * const kStationLongitude;
extern NSString * const kStationTypes;
extern NSString * const kStationID;

extern NSString * const StationFetcherErrorDomain;

typedef NS_ENUM(NSUInteger, StationFetcherErrorCode) {
    StationFetcherErrorCodeOverLimit = 1,
    StationFetcherErrorCodeRequestDenied,
    StationFetcherErrorCodeInvalidResponse,
    StationFetcherErrorCodeConnectionError
};

@interface StationFetcher : NSObject
+ (instancetype)defaultFetcher;
- (void)findByName:(NSString *)searchName completed:(void (^)(NSArray *stations))block error:(void (^)(NSError *error))error;
@end
