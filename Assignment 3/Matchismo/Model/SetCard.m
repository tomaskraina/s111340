//
//  SetCard.m
//  Matchismo
//
//  Created by Tom on 05.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "SetCard.h"

NSString * const SetCardSymbol_toString[] = {@"▲", @"■", @"●"};
NSString * const SetCardShading_toString[] = {@"open", @"stripped", @"solid"};
NSString * const SetCardColor_toString[] = {@"red", @"purple", @"green"};

@implementation SetCard

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
    else if (!(self.symbol == card2.symbol && self.symbol == card3.symbol)
             && !(self.symbol != card2.symbol && self.symbol != card3.symbol && card2.symbol != card3.symbol)) {
        return 0;
    }
    else if (!(self.shading == card2.shading && self.shading == card3.shading)
             && !(self.shading != card2.shading && self.shading != card3.shading && card2.shading != card3.shading)) {
        return 0;
    }
    else if (!(self.color == card2.color && self.color == card3.color)
             && !(self.color != card2.color && self.color != card3.color && card2.color != card3.color)) {
        return 0;
    }
    
    return 1;
}


- (void)setColor:(SetCardColor)color
{
    if ([[SetCard validColors] containsObject:@( color )]) {
        _color = color;
    }
}

- (void)setSymbol:(SetCardSymbol)symbol
{
    if ([[SetCard validSymbols] containsObject:@( symbol )]) {
        _symbol = symbol;
    }
}

- (void)setShading:(SetCardShading)shading
{
    if ([[SetCard validShadings] containsObject:@( shading )]) {
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
    return [@"" stringByPaddingToLength:self.number withString:SetCardSymbol_toString[self.symbol] startingAtIndex:0];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@", [self contents], SetCardShading_toString[self.shading], SetCardColor_toString[self.color]];
}

+ (NSUInteger)maxNumber
{
    return 3;
}

+ (NSArray *)validSymbols
{
    static NSArray *array;
    if (!array) {
        array = @[@(SetCardSymbolDiamond), @(SetCardSymbolSquiggle), @(SetCardSymbolOval) ];
    }
    return array;
}

+ (NSArray *)validShadings
{
    static NSArray *array;
    if (!array) {
        array = @[ @(SetCardShadingOpen), @(SetCardShadingSolid), @(SetCardShadingStripped) ];
    }
    return array;
}

+ (NSArray *)validColors
{
    static NSArray *array;
    if (!array) {
        array = @[ @(SetCardColorGreen), @(SetCardColorPurple), @(SetCardColorRed) ];
    }
    return array;
}

- (BOOL)isEqual:(SetCard *)object
{
    if (![object isKindOfClass:[SetCard class]]) {
        return NO;
    }
    
    return object.number == self.number && object.symbol == self.symbol && object.shading == self.shading && object.color == self.color;
}

@end
