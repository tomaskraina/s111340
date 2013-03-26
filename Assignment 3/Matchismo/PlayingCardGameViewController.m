//
//  PlayingCardGameViewController.m
//  Matchismo
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University.
//  All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "PlayingCardCollectionViewCell.h"

@implementation PlayingCardGameViewController

#pragma mark - Properties

- (CardMatchingGameMode)gameMode
{
    return CardMatchingGameModeMatch2Cards;
}

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}

- (NSString *)gameTypeName
{
    static NSString *gameTypeName = @"Matchismo";
    return gameTypeName;
}

- (NSUInteger)startingCardCount
{
    return 22;
}

- (void)updateCell:(PlayingCardCollectionViewCell *)cell usingCard:(PlayingCard *)card animated:(BOOL)animated
{
    if ([cell isKindOfClass:[PlayingCardCollectionViewCell class]] && [card isKindOfClass:[PlayingCard class]]) {
        cell.playingCardView.rank = card.rank;
        cell.playingCardView.suit = card.suit;
        cell.playingCardView.alpha = card.isUnplayable ? 0.3 : 1.0;
        if (animated && cell.playingCardView.faceUp != card.isFaceUp) {
            [UIView transitionWithView:cell.playingCardView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                    cell.playingCardView.faceUp = card.isFaceUp;
            } completion:NULL];
        }
        else {
            cell.playingCardView.faceUp = card.isFaceUp;
        }
    }
}

- (NSAttributedString *)attributedStringForCard:(Card *)card
{
    return [[NSAttributedString alloc] initWithString:[card contents]];
}

@end
