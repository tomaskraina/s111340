//
//  SetCard.m
//  Matchismo
//
//  Created by Tom on 05.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "SetCard.h"

@implementation SetCard

NSString* const SetCardOpenShading = @"SetCardOpenShading";
NSString* const SetCardStrippedShading = @"SetCardStrippedShading";
NSString* const SetCardSolidShading = @"SetCardSolidShading";

NSString* const SetCardRedColor = @"SetCardRedColor";
NSString* const SetCardGreenColor = @"SetCardGreenColor";
NSString* const SetCardPurpleColor = @"SetCardPurpleColor";


- (int)match:(NSArray *)otherCards
{
    if ([otherCards count] != 2) {
        return 0;
    }
    
    SetCard *card2 = [otherCards[0] isKindOfClass:[SetCard class]] ? otherCards[0] : nil;
    SetCard *card3 = [otherCards[1] isKindOfClass:[SetCard class]] ? otherCards[1] : nil;
    
    if (!(self.number == card2.number && self.number == card3.number) && !(self.number != card2.number && self.number != card3.number && card2.number != card3.number)) {
        return 0;
    }
    else if (!([self.symbol isEqual:card2.symbol] && [self.symbol isEqual:card3.symbol])
             && !(![self.symbol isEqual:card2.symbol] && ![self.symbol isEqual:card3.symbol] && ![card2.symbol isEqual:card3.symbol])) {
        return 0;
    }
    else if (!([self.shading isEqual:card2.shading] && [self.shading isEqual:card3.shading])
             && !(![self.shading isEqual:card2.shading] && ![self.shading isEqual:card3.shading] && ![card2.shading isEqual:card3.shading])) {
        return 0;
    }
    else if (!([self.color isEqual:card2.color] && [self.color isEqual:card3.color])
             && !(![self.color isEqual:card2.color] && ![self.color isEqual:card3.color] && ![card2.color isEqual:card3.color])) {
        return 0;
    }
    
    return 1;
}


- (void)setColor:(id)color
{
    if ([[SetCard validColors] containsObject:color]) {
        _color = color;
    }
}

- (void)setSymbol:(NSString *)symbol
{
    if ([[SetCard validSymbols] containsObject:symbol]) {
        _symbol = symbol;
    }
}

- (void)setShading:(id)shading
{
    if ([[SetCard validShadings] containsObject:shading]) {
        _shading = shading;
    }
}

- (void)setNumber:(NSUInteger)number
{
    if (number > 0 && number <= [SetCard maxNumber]) {
        _number = number;
    }
}

- (NSString *)contents
{
    return [self.symbol stringByPaddingToLength:self.number withString:self.symbol startingAtIndex:0];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {%@, %@}", [self contents], self.shading, self.color];
}

+ (NSUInteger)maxNumber
{
    return 3;
}

+ (NSArray *)validSymbols
{
    static NSArray *array;
    if (!array) {
        array = @[@"▲", @"●", @"■"];
    }
    return array;
}

+ (NSArray *)validShadings
{
    static NSArray *array;
    if (!array) {
        array = @[SetCardOpenShading, SetCardSolidShading, SetCardStrippedShading];
    }
    return array;
}

+ (NSArray *)validColors
{
    static NSArray *array;
    if (!array) {
        array = @[SetCardRedColor, SetCardGreenColor, SetCardPurpleColor];
    }
    return array;
}

@end
