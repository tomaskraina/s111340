//
//  FileCache.m
//  SPoT
//
//  Created by Tom K on 4/21/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "FileCache.h"

#define DEFAULT_DIRECTORY @"FileCache"
#define DEFAULT_LIMIT_SIZE 1*1024*1024 // 1MB

@implementation FileCache

- (id)init
{
    self = [super init];
    if (self) {
        // set up
        NSFileManager *manager = [[NSFileManager alloc] init];
        [manager createDirectoryAtURL:[self cacheDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
        self.limit = DEFAULT_LIMIT_SIZE;
    }
    return self;
}

+ (FileCache *)sharedCache
{
    static FileCache *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FileCache alloc] init];
    });
    
    return sharedInstance;
}

- (void)purge
{
    NSFileManager *manager = [[NSFileManager alloc] init];
    [manager removeItemAtURL:[self cacheDirectory] error:nil];
    [manager createDirectoryAtURL:[self cacheDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
}

- (unsigned long long)cacheSize
{
    unsigned long long filesize = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    NSArray *fileURLs = [fileManager contentsOfDirectoryAtURL:[self cacheDirectory] includingPropertiesForKeys:nil options:0 error:nil];
    for (NSURL *fileURL in fileURLs) {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:[fileURL path] error:nil];
        filesize += [attributes fileSize];
    }
    
    return filesize;

}

- (void)deleteOldestAccessedFile
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *fileURLs = [fileManager contentsOfDirectoryAtURL:[self cacheDirectory] includingPropertiesForKeys:@[NSURLContentAccessDateKey] options:0 error:nil];
    NSArray *sortedURLs = [fileURLs sortedArrayUsingComparator:^NSComparisonResult(NSURL *obj1, NSURL *obj2) {
        NSDate *date1 = [obj1 resourceValuesForKeys:@[NSURLContentAccessDateKey] error:nil][NSURLContentAccessDateKey];
        NSDate *date2 = [obj2 resourceValuesForKeys:@[NSURLContentAccessDateKey] error:nil][NSURLContentAccessDateKey];
        return [date2 compare:date1]; // DESC
    }];
    
    [fileManager removeItemAtURL:[sortedURLs lastObject] error:nil];
}

- (void)setData:(NSData *)data forKey:(NSString *)aKey
{
    if (!aKey) {
        [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key can't be nil" userInfo:nil];
    }
    
    if ([data length] >= self.limit) {
        return;
    }
    
    while ([self cacheSize] + [data length] >= self.limit) {
        [self deleteOldestAccessedFile];
    }
    
    NSURL *fileURL = [[self cacheDirectory] URLByAppendingPathComponent:aKey];
    [data writeToURL:fileURL atomically:YES];
}

- (NSURL *)cacheDirectory
{
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSArray *urls = [manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    
    NSURL *cacheURL = [(NSURL *)[urls lastObject] URLByAppendingPathComponent:DEFAULT_DIRECTORY isDirectory:YES];

    return cacheURL;
}

- (NSData *)dataForKey:(NSString *)aKey
{
    NSURL *fileURL = [[self cacheDirectory] URLByAppendingPathComponent:aKey];
    return [NSData dataWithContentsOfURL:fileURL];
}

@end
