//
//  SetCard.h
//  Matchismo
//
//  Created by Tom on 05.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "Card.h"

// extern const does keeps type checking in game, #define is simply a text replacement in preprocessor
extern NSString* const SetCardOpenShading;
extern NSString* const SetCardStrippedShading;
extern NSString* const SetCardSolidShading;

extern NSString* const SetCardRedColor;
extern NSString* const SetCardGreenColor;
extern NSString* const SetCardPurpleColor;

@interface SetCard : Card
@property (nonatomic) NSUInteger number;
@property (strong, nonatomic) NSString *symbol;
@property (strong, nonatomic) id shading;
@property (strong, nonatomic) id color;

+ (NSUInteger)maxNumber;
+ (NSArray *)validSymbols;
+ (NSArray *)validShadings;
+ (NSArray *)validColors;

@end
