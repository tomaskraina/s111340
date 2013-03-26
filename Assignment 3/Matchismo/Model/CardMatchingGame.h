//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Tom Kraina on 03.02.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

typedef enum {
    CardMatchingGameModeMatch2Cards = 2,
    CardMatchingGameModeMatch3Cards = 3
} CardMatchingGameMode;

@class CardMatchingGame;

@protocol CardMatchingGameDelegate <NSObject>
@optional
- (void)cardMatchingGame:(CardMatchingGame *)game
             didFlipCard:(Card *)card;
- (void)cardMatchingGame:(CardMatchingGame *)game
                   cards:(NSArray *)cards
       didMatchWithScore:(NSInteger)score;
@end


@interface CardMatchingGame : NSObject

- (id)initWithCardCount:(NSUInteger)count
              usingDeck:(Deck *)deck
                   mode:(CardMatchingGameMode)mode;
- (void)flipCardAtIndex:(NSUInteger)index;
- (Card *)cardAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfCard:(Card *)card;
- (NSIndexSet *)addMoreCardsToGame:(NSUInteger)numberOfCards usingDeck:(Deck *)deck;

@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly) CardMatchingGameMode mode;
@property (weak, nonatomic) id<CardMatchingGameDelegate> delegate;
@property (nonatomic, readonly) NSUInteger numberOfCards;

@end
