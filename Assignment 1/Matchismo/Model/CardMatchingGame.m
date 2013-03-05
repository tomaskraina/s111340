//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Tom Kraina on 03.02.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "CardMatchingGame.h"


@interface CardMatchingGame()
@property (strong, nonatomic) NSMutableArray *cards; // of Card
@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, readwrite) CardMatchingGameMode mode;
@end

@implementation CardMatchingGame

- (NSMutableArray *)cards
{
    if (!_cards) {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}

- (id)initWithCardCount:(NSUInteger)count
              usingDeck:(Deck *)deck
                   mode:(CardMatchingGameMode)mode
{
    self = [super init];
    
    if (self) {
        self.mode = mode;
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (!card) {
                self = nil;
            }
            else {
                self.cards[i] = card;
            }
        }
    }
    
    return self;
}

- (Card *)cardAtIndex:(NSUInteger)index
{
    return (index < self.cards.count) ? self.cards[index] : nil;
}

#define FLIP_COST 1
#define MISMATCH_PENALTY 2
#define MATCH_BONUS 4

- (void)makeCardsUnplayable:(NSArray *)cards
{
    for (Card *card in cards) {
        card.unplayable = YES;
    }
}

- (void)flipCards:(NSArray *)cards {
    for (Card *card in cards) {
        card.faceUp = !card.isFaceUp;
    }
}

- (void)flipCardAtIndex:(NSUInteger)index
{
    Card *card = self.cards[index];
    
    if (!card.isUnplayable) {
        card.faceUp = !card.isFaceUp;
        
        if (card.isFaceUp) {
            self.score -= FLIP_COST;
            
            [self matchFlippedUpCard:card];
        }
        else {
            [self.delegate cardMatchingGame:self didFlipCard:card];
        }
    }

}

- (NSArray *)facedUpCards
{
    NSMutableArray *facedUpCards = [[NSMutableArray alloc] init];
    
    for (Card *card in self.cards) {
        if (card.isFaceUp && !card.isUnplayable) {
            [facedUpCards addObject:card];
        }
    }
    
    return [facedUpCards copy];
}

- (void)matchFlippedUpCard:(Card *)card
{
    NSArray *cardsToMatch = [self facedUpCards];
    
    if ([cardsToMatch count] == self.mode) {
        NSInteger matchScore = [self matchScoreForCards:cardsToMatch];
        
        if (matchScore > 0) {
            [self makeCardsUnplayable:cardsToMatch];
        }
        else {
            [self flipCards:cardsToMatch];
            card.faceUp = YES; // Keep the last flipped card faced up
        }
        
        self.score += matchScore;
        [self.delegate cardMatchingGame:self cards:cardsToMatch didMatchWithScore:matchScore];
    }
    else {
        [self.delegate cardMatchingGame:self didFlipCard:card];
    }
}

- (NSInteger)matchScoreForCards:(NSArray *)cards
{
    NSInteger matchScore = 0;
    
    // Matches every two cards against each other once and only once
    for (NSUInteger i = 0; i < ([cards count] - 1); i++) {
        NSRange rangeToMatch = NSMakeRange(i + 1, ([cards count] - i - 1));
        NSUInteger score = [cards[i] match:[cards subarrayWithRange:rangeToMatch]];
        matchScore += score ? (score * MATCH_BONUS) : (score - MISMATCH_PENALTY);
    }
        
    return matchScore;
}


@end
