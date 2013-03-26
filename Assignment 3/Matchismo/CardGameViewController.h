//
//  CardGameViewController.h
//  Matchismo
//
//  Created by Tom Kraina on 03.02.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardMatchingGame.h"
@class Card;
@class Deck;

@interface CardGameViewController : UIViewController

// implement in subclass
- (NSUInteger)startingCardCount;
- (CardMatchingGameMode)gameMode;
- (Deck *)createDeck;
- (NSString *)gameTypeName;
- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card animated:(BOOL)animated;
- (NSAttributedString *)attributedStringForCard:(Card *)card;

// optional
@property (nonatomic, readonly) BOOL removesUnplayableCards; // default is NO

@end
