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
- (CardMatchingGameMode)gameMode;
- (Deck *)deck;
- (void)configureCardButton:(UIButton *)cardButton forCard:(Card *)card;
- (NSAttributedString *)attributedStringForCard:(Card *)card;
//- (void)gameDidReset;
//- (void)cardDidFlip;
@end
