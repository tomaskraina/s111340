//
//  Recents.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/10/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "Recents.h"

NSUInteger const RECENTS_DEFAULT_LIMIT = 15;

NSString * const kRecentsAll = @"recents-all";
NSString * const kRecentDatetime = @"datetime-added";
NSString * const kRecentID = @"id";

@implementation Recents

#pragma mark - Init methods

- (NSArray *)allRecents
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRecentsAll];
}

- (void)addObject:(NSDictionary *)object
{
    NSMutableArray *allRecents = [[self allRecents] mutableCopy];
    if (!allRecents) {
        allRecents = [NSMutableArray array];
    }
    
    [allRecents filterUsingPredicate:[NSPredicate predicateWithFormat:@"%K != %@", kRecentID, object[kRecentID]]];
    
    NSMutableDictionary *mutableObject = [object mutableCopy];
    [mutableObject setObject:[NSDate date] forKey:kRecentDatetime];
    [allRecents insertObject:mutableObject atIndex:0];

    while ([allRecents count] > self.limit) {
        [allRecents removeLastObject];
    }

    [[NSUserDefaults standardUserDefaults] setObject:allRecents forKey:kRecentsAll];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)eraseRecents
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRecentsAll];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _limit = RECENTS_DEFAULT_LIMIT;
    }
    
    return self;
}

+ (instancetype)defaultRecents
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
