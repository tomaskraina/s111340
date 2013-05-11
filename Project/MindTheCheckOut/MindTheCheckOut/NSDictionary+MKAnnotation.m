//
//  NSDictionary+MKAnnotation.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/11/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "NSDictionary+MKAnnotation.h"
#import "StationFetcher.h"

@implementation NSDictionary (MKAnnotation)

- (CLLocationCoordinate2D) coordinate
{
    return CLLocationCoordinate2DMake([self[kStationLatitude] doubleValue], [self[kStationLongitude] doubleValue]);
}

- (NSString *)title
{
    return self[kStationName];
}

@end
