//
//  FileCache.h
//  SPoT
//
//  Created by Tom K on 4/21/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject

@property (nonatomic) unsigned long long limit;

+ (FileCache *)sharedCache;

- (void)purge;
- (void)setData:(NSData *)data forKey:(NSString *)aKey;
- (NSData *)dataForKey:(NSString *)aKey;

@end
