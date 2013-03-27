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
const NSUInteger CardGameMaxCardsToDeal = 56;
NSString * const CardGameTypeName = @"Playing Card Game";

@interface PlayingCardGameViewController () <UIAlertViewDelegate>
@property (nonatomic) NSUInteger numberOfCardsToDeal;
@end

@implementation PlayingCardGameViewController

#pragma mark - Properties

- (NSUInteger)numberOfCardsToDeal
{
    if (_numberOfCardsToDeal < 2) {
        _numberOfCardsToDeal = CardStartingCount;
    }
    
    return _numberOfCardsToDeal;
}

#pragma mark - Mandatory overrides

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
    return self.numberOfCardsToDeal;
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

#pragma mark - IBActions

#define COUNT_LABEL_TAG 1024

- (IBAction)showResetConfirmation:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Redeal", @"PlayingCardViewController - alert - title") message:[NSString stringWithFormat:@"%@\n\n\n", NSLocalizedString(@"Select number of cards to deal", @"PlayingCardViewController - alert - message")] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"PlayingCardViewController - alert - cancel") otherButtonTitles:NSLocalizedString(@"Deal", @"PlayingCardViewController - alert - deal"), nil];
    
    [self addCountLabelToAlertView:alert];
    [self addStepperToAlertView:alert];
    
    [alert show];
}

#pragma mark - Convinience methods

- (void)addStepperToAlertView:(UIAlertView *)alert
{
    UIStepper* stepper = [[UIStepper alloc] init];
    stepper.frame = CGRectMake(115.0, 80.0, 100, 28);
    stepper.value = self.startingCardCount;
    stepper.minimumValue = self.gameMode;
    stepper.maximumValue = CardGameMaxCardsToDeal;
    [stepper addTarget:self action:@selector(changeNumberOfCards:) forControlEvents:UIControlEventValueChanged];
    
    [alert addSubview:stepper];
}

- (void)addCountLabelToAlertView:(UIAlertView *)alert
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(85., 80., 20, 28)];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    label.text = [NSString stringWithFormat:@"%d", self.startingCardCount];
    label.tag = COUNT_LABEL_TAG;

    [alert addSubview:label];
}

- (IBAction)changeNumberOfCards:(UIStepper *)sender
{
    UILabel *label = (UILabel *)[sender.superview viewWithTag:COUNT_LABEL_TAG];
    label.text = [NSString stringWithFormat:@"%d", (int) ceil(sender.value)];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        UILabel *label = (UILabel *)[alertView viewWithTag:COUNT_LABEL_TAG];
        self.numberOfCardsToDeal = [label.text integerValue];
        [self resetGame:self];
    }
}

@end
