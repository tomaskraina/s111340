//
//  PlayingCard.m
//  Matchismo
//
//  Created by Tom Kraina on 03.02.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

- (NSString *)contents
{
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

- (int)matchCard:(PlayingCard *)otherCard
{
    int score = 0;
    
    if ([otherCard.suit isEqualToString:self.suit]) {
        score = 1;
    }
    else if (otherCard.rank == self.rank) {
        score = 4;
    }
    
    return score;
}

- (int)match:(NSArray *)otherCards
{
    int score = 0;
    
    for (Card *otherCard in otherCards) {
        if ([otherCard isKindOfClass:[PlayingCard class]]) {
            score += [self matchCard:(PlayingCard *)otherCard];
        }
    }
    
    return score;
}

@synthesize suit = _suit;

+ (NSArray *)validSuits
{
    static NSArray *validSuits = nil;
    if (!validSuits) {
        validSuits = @[@"♠", @"♣", @"♥", @"♦"];
    }
    
    return validSuits;
}

- (void)setSuit:(NSString *)suit
{
    if ([[PlayingCard validSuits] containsObject:suit]) {
        _suit = suit;
    }
}

- (NSString *)suit
{
    return _suit ? _suit : @"?";
}

+ (NSArray *)rankStrings
{
    static NSArray *rankStrings = nil;
    if (!rankStrings) {
        rankStrings = @[@"?", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"J", @"Q", @"K", @"A"];
    }
    
    return rankStrings;
}

+ (NSUInteger)maxRank
{
    return [[PlayingCard rankStrings] count] - 1;
}

@end
