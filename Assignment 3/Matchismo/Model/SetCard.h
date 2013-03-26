//
//  SetCard.h
//  Matchismo
//
//  Created by Tom on 05.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "Card.h"

typedef NS_ENUM(NSUInteger, SetCardSymbol) {
    SetCardSymbolDiamond,
    SetCardSymbolSquiggle,
    SetCardSymbolOval
};

typedef NS_ENUM(NSUInteger, SetCardShading) {
    SetCardShadingOpen,
    SetCardShadingStripped,
    SetCardShadingSolid
};

typedef NS_ENUM(NSUInteger, SetCardColor) {
    SetCardColorRed,
    SetCardColorPurple,
    SetCardColorGreen
};

@interface SetCard : Card
@property (nonatomic) NSUInteger number;
@property (nonatomic) SetCardSymbol symbol;
@property (nonatomic) SetCardShading shading;
@property (nonatomic) SetCardColor color;

+ (NSUInteger)maxNumber;
+ (NSArray *)validSymbols; // of NSNumber
+ (NSArray *)validShadings; // of NSNumber
+ (NSArray *)validColors; // of NSNumber

@end
