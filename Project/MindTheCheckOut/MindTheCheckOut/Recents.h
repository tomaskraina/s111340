//
//  Recents.h
//  MindTheCheckOut
//
//  Created by Tom K on 5/10/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSUInteger const RECENTS_DEFAULT_LIMIT;

@interface Recents : NSObject
@property (nonatomic) NSUInteger limit;
+ (instancetype)defaultRecents;
- (void)addObject:(NSDictionary *)station;
- (NSArray *)allRecents;
- (void)eraseRecents;
@end
