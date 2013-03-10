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
@property (weak, nonatomic) IBOutlet UISlider *historySlider;
@property (strong, nonatomic) NSMutableArray *history;
@end

@implementation CardGameViewController

- (NSMutableArray *)history
{
    if (!_history) {
        _history = [NSMutableArray arrayWithObject:[[NSAttributedString alloc] init]];
    }
    
    return _history;
}

- (void)setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
    NSLog(@"flips updated to %d", self.flipCount);
}

- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                  usingDeck:[self deck]
                                                       mode:[self gameMode]];
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
        [self configureCardButton:cardButton forCard:card];
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.game.score];
    self.descriptionLabel.attributedText = [self.history lastObject];
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
    
//    [self gameDidReset];
}

- (IBAction)flipCard:(UIButton *)sender
{
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    self.flipCount++;
    
    [self updateUI];
    
//    [self cardDidFlip];
}


- (IBAction)showHistory:(UISlider *)sender
{
    self.descriptionLabel.alpha = sender.value == sender.maximumValue ? 1. : .5;
    self.descriptionLabel.attributedText = self.history[(int)sender.value - 1];
}


- (NSAttributedString *)cards:(NSArray *)cards joinedByString:(NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < [cards count]; i++) {
        [attributedString appendAttributedString:[self attributedStringForCard:cards[i]]];
        
        if (i < [cards count] - 1) {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        }
    }
    
    return attributedString;
}

#pragma mark CardMatchingGameDelegate

- (void)cardMatchingGame:(CardMatchingGame *)game cards:(NSArray *)cards didMatchWithScore:(NSInteger)score
{
    NSMutableAttributedString *text;
    if (score > 0) {
        text = [[NSMutableAttributedString alloc] initWithString:@"Matched "];
        [text appendAttributedString:[self cards:cards joinedByString:@", "]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" for %d point", score]]];
    }
    else {
        text = [[NSMutableAttributedString alloc] initWithAttributedString:[self cards:cards joinedByString:@", "]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" don't match! Penalty %d points", -score]]];
    }
    
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, [text length])];
    
    [self.history addObject:text];
}

- (void)cardMatchingGame:(CardMatchingGame *)game didFlipCard:(Card *)card
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Flipped %@ ", card.faceUp ? @"up" : @"down"]];
    [attributedString appendAttributedString:[self attributedStringForCard:card]];
    [self.history addObject:attributedString];
}


// Implement in subclass
- (CardMatchingGameMode)gameMode
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}
- (Deck *)deck
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (void)configureCardButton:(UIButton *)cardButton forCard:(Card *)card
{
    [self doesNotRecognizeSelector:_cmd];
}
- (NSAttributedString *)attributedStringForCard:(Card *)card
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
//- (void)gameDidReset
//{
//    [self doesNotRecognizeSelector:_cmd];
//}
//- (void)cardDidFlip
//{
//    [self doesNotRecognizeSelector:_cmd];
//}


@end
