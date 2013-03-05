//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Tom Kraina on 03.02.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "CardGameViewController.h"
#import "PlayingCardDect.h"
#import "CardMatchingGame.h"

@interface CardGameViewController () <CardMatchingGameDelegate>
@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) int flipCount;
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cardModeControl;
@property (weak, nonatomic) IBOutlet UISlider *historySlider;
@property (strong, nonatomic) NSMutableArray *history;
@end

@implementation CardGameViewController

- (NSMutableArray *)history
{
    if (!_history) {
        _history = [NSMutableArray arrayWithObject:@"New game"];
    }
    
    return _history;
}

- (void)setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.cardModeControl.enabled = flipCount == 0;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
    NSLog(@"flips updated to %d", self.flipCount);
}

- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                  usingDeck:[[PlayingCardDect alloc] init]
                                                       mode:CardMatchingGameModeMatch2Cards];
        _game.delegate = self;
    }
    
    return _game;
}

- (void)setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    [self updateUI];
}

- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons) {
        Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        [cardButton setTitle:card.contents forState:UIControlStateSelected];
        [cardButton setTitle:card.contents forState:UIControlStateSelected|UIControlStateDisabled];
        cardButton.selected = card.isFaceUp;
        cardButton.enabled = !card.isUnplayable;
        cardButton.alpha = card.isUnplayable ? 0.3 : 1.0;
        
        UIImage *backImage = card.isFaceUp ? nil : [UIImage imageNamed:@"card-back"];
        [cardButton setImage:backImage forState:UIControlStateNormal];
        [cardButton setImageEdgeInsets:UIEdgeInsetsMake(6, 10, 6, 10)];
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.game.score];
    self.descriptionLabel.text = [self.history lastObject];
    self.descriptionLabel.alpha = 1.;
    self.historySlider.maximumValue = [self.history count];
    self.historySlider.value = self.historySlider.maximumValue;
}


#pragma mark IBActions

- (IBAction)resetGame:(id)sender
{
    self.game = nil;
    self.flipCount = 0;
    self.history = nil;
    
    [self updateUI];
}

- (IBAction)flipCard:(UIButton *)sender
{
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    self.flipCount++;
    
    [self updateUI];
}


#define SEGMENTED_CONTROL_3_CARD_MATCH_MODE_SEGMENT 1

- (IBAction)changeGameMode:(UISegmentedControl *)sender
{
    PlayingCardDect *deck = [[PlayingCardDect alloc] init];
    
    switch (sender.selectedSegmentIndex) {
        case SEGMENTED_CONTROL_3_CARD_MATCH_MODE_SEGMENT :
            self.game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                          usingDeck:deck
                                                               mode:CardMatchingGameModeMatch3Cards];
            break;
            
        default:
            self.game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                          usingDeck:deck
                                                               mode:CardMatchingGameModeMatch2Cards];
            break;
    }
    
    self.game.delegate = self;
}

- (IBAction)showHistory:(UISlider *)sender
{
    self.descriptionLabel.alpha = sender.value == sender.maximumValue ? 1. : .5;
    self.descriptionLabel.text = self.history[(int)sender.value - 1];
}


#pragma mark CardMatchingGameDelegate

- (void)cardMatchingGame:(CardMatchingGame *)game cards:(NSArray *)cards didMatchWithScore:(NSInteger)score
{
    NSString *text;
    if (score > 0) {
        text = [NSString stringWithFormat:@"Matched %@ for %d points", [cards componentsJoinedByString:@" and "], score];
    }
    else {
        text = [NSString stringWithFormat:@"%@ don't match! Penalty %d points", [cards componentsJoinedByString:@" and "], -score];
    }
    
    [self.history addObject:text];
}

- (void)cardMatchingGame:(CardMatchingGame *)game didFlipCard:(Card *)card
{
    [self.history addObject:[NSString stringWithFormat:@"Flipped %@ %@", card.faceUp ? @"up" : @"down", card.contents]];
}

@end
