//
//  RecentPhotos.h
//  SPoT
//
//  Created by Tom K on 4/11/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotos : NSObject
+ (NSArray *)allPhotos; // of NSDictionary
+ (void)addPhoto:(NSDictionary *)photoInfo;
@end
