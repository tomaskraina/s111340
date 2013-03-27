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

const CGFloat CardAlphaUnplayable = .3;
const CGFloat CardAlphaPlayable = 1.;
const CGFloat CardTransformationDuration = .3;
const NSUInteger CardStartingCount = 22;
NSString * const CardGameTypeName = @"Playing Card Game";

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
    return CardGameTypeName;
}

- (NSUInteger)startingCardCount
{
    return CardStartingCount;
}

- (void)updateCell:(PlayingCardCollectionViewCell *)cell usingCard:(PlayingCard *)card animated:(BOOL)animated
{
    if ([cell isKindOfClass:[PlayingCardCollectionViewCell class]] && [card isKindOfClass:[PlayingCard class]]) {
        cell.playingCardView.rank = card.rank;
        cell.playingCardView.suit = card.suit;
        cell.playingCardView.alpha = card.isUnplayable ? CardAlphaUnplayable : CardAlphaPlayable;
        if (animated && cell.playingCardView.faceUp != card.isFaceUp) {
            [UIView transitionWithView:cell.playingCardView duration:CardTransformationDuration options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
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
