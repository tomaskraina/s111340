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

@interface StationFetcher : NSObject
+ (instancetype)defaultFetcher;
- (void)findByName:(NSString *)name completed:(void (^)(NSArray *stations))block;
@end
