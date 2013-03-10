//
//  MatchizmoGameViewController.m
//  Matchismo
//
//  Created by Tom on 07.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "MatchizmoGameViewController.h"
#import "Card.h"
#import "PlayingCardDect.h"

@interface MatchizmoGameViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *cardModeControl;
@end

@implementation MatchizmoGameViewController

- (CardMatchingGameMode)gameMode
{
    return CardMatchingGameModeMatch2Cards;
}

- (Deck *)deck
{
    return [[PlayingCardDect alloc] init];
}

- (NSAttributedString *)attributedStringForCard:(Card *)card
{
    return [[NSAttributedString alloc] initWithString:[card contents]];
}

- (void)configureCardButton:(UIButton *)cardButton forCard:(Card *)card
{
    [cardButton setTitle:card.contents forState:UIControlStateSelected];
    [cardButton setTitle:card.contents forState:UIControlStateSelected|UIControlStateDisabled];
    cardButton.selected = card.isFaceUp;
    cardButton.enabled = !card.isUnplayable;
    cardButton.alpha = card.isUnplayable ? 0.3 : 1.0;
    
    UIImage *backImage = card.isFaceUp ? nil : [UIImage imageNamed:@"card-back"];
    [cardButton setImage:backImage forState:UIControlStateNormal];
    [cardButton setImageEdgeInsets:UIEdgeInsetsMake(6, 10, 6, 10)];
}

//- (void)gameDidReset
//{
//    self.cardModeControl.enabled = YES;
//}
//
//- (void)cardDidFlip
//{
//    self.cardModeControl.enabled = NO;
//}
//
//#define SEGMENTED_CONTROL_3_CARD_MATCH_MODE_SEGMENT 1
//
//- (IBAction)changeGameMode:(UISegmentedControl *)sender
//{
//    Deck *deck = [self deck];
//    
//    switch (sender.selectedSegmentIndex) {
//        case SEGMENTED_CONTROL_3_CARD_MATCH_MODE_SEGMENT :
//            self.game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
//                                                          usingDeck:deck
//                                                               mode:CardMatchingGameModeMatch3Cards];
//            break;
//            
//        default:
//            self.game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
//                                                          usingDeck:deck
//                                                               mode:CardMatchingGameModeMatch2Cards];
//            break;
//    }
//    
//    self.game.delegate = self;
//}

@end
