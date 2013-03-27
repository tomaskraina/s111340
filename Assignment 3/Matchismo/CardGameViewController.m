//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Tom Kraina on 03.02.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "CardGameViewController.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"
#import "GameResult.h"

#import "SetCardCollectionViewCell.h"

@interface CardGameViewController () <CardMatchingGameDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *miniCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) Deck *deck;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) NSMutableArray *history;
@property (strong, nonatomic) GameResult *gameResult;
@property (weak, nonatomic) IBOutlet UIButton *addCardsButton;
@property (strong, nonatomic) NSMutableArray *deckIndicesOfVisibleCards;

@end

@implementation CardGameViewController

#pragma mark - Properties

- (NSMutableArray *)deckIndicesOfVisibleCards
{
    if (!_deckIndicesOfVisibleCards) {
        _deckIndicesOfVisibleCards = [NSMutableArray array];
    }
    
    return _deckIndicesOfVisibleCards;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    if (_collectionView != collectionView) {
        _collectionView = collectionView;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
}

- (void)setMiniCollectionView:(UICollectionView *)collectionView
{
    if (_miniCollectionView != collectionView) {
        _miniCollectionView = collectionView;
        _miniCollectionView.delegate = self;
        _miniCollectionView.dataSource = self;
    }
}

- (GameResult *)gameResult
{
    if (!_gameResult) {
        _gameResult = [[GameResult alloc] initWithGameType:[self gameTypeName]];
    }
    return _gameResult;
}

- (Deck *)deck
{
    if (!_deck) {
        _deck = [self createDeck];
    }
    
    return _deck;
}

- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:self.startingCardCount
                                                  usingDeck:self.deck
                                                       mode:[self gameMode]];
        _game.delegate = self;
    }
    
    return _game;
}

- (NSMutableArray *)history
{
    if (!_history) {
        _history = [NSMutableArray arrayWithObject:[[NSAttributedString alloc] init]];
    }
    
    return _history;
}

#pragma mark - UIViewController life cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.deckIndicesOfVisibleCards count] == 0) {
        [self dealCards];
    }
}

#pragma mark - Updating the UI

- (void)updateUI
{
    [self.miniCollectionView reloadData];
    
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSInteger deckIndex = [self.deckIndicesOfVisibleCards[indexPath.item] integerValue];
        Card *card = [self.game cardAtIndex:deckIndex];
        [self updateCell:cell usingCard:card animated:YES];
    }
    
    [self updateUIwithoutCollectionView];
}

- (void)updateUIwithoutCollectionView
{
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.game.score];
    self.descriptionLabel.attributedText = [self.history lastObject];
    self.descriptionLabel.alpha = 1.;
}

- (void)dealCards
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < self.game.numberOfCards; i++) {
        [self.deckIndicesOfVisibleCards addObject:@(i)];
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    
    [self.collectionView performSelector:@selector(insertItemsAtIndexPaths:) withObject:indexPaths afterDelay:0.1];
}

- (void)hideUnplayableCards:(NSArray *)cards
{
    // Get index paths of cards
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (Card *matchCard in cards) {
        NSUInteger deckIndex = [self.game indexOfCard:matchCard];
        NSUInteger cellIndes = [self.deckIndicesOfVisibleCards indexOfObject:@(deckIndex)];
        [indexSet addIndex:cellIndes];
        [indexPaths addObject:[NSIndexPath indexPathForItem:cellIndes inSection:0]];
    }
    
    [self.deckIndicesOfVisibleCards removeObjectsAtIndexes:indexSet];
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
}


#pragma mark - IBActions

- (IBAction)resetGame:(id)sender
{
    NSMutableArray *indexPathsToDelete = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.deckIndicesOfVisibleCards count]; i++) {
        [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    
    self.deck = nil;
    self.game = nil;
    self.history = nil;
    self.gameResult = nil;
    self.deckIndicesOfVisibleCards = nil;
    [self.collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
    
    self.addCardsButton.enabled = YES;
    [self dealCards];
    
    [self updateUIwithoutCollectionView];
}

#define NUMBER_OF_CARDS_TO_ADD 3

- (IBAction)addCardsToGame:(id)sender
{
    NSIndexSet *indexSet = [self.game addMoreCardsToGame:NUMBER_OF_CARDS_TO_ADD usingDeck:self.deck];
    if (indexSet) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [self.deckIndicesOfVisibleCards addObject:@( idx )];
            NSUInteger index = [self.deckIndicesOfVisibleCards indexOfObject:@( idx )];
            [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }];
        
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        [self.collectionView scrollToItemAtIndexPath:[indexPaths lastObject] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        
        [self updateUIwithoutCollectionView];
    }
    else {
        self.addCardsButton.enabled = NO;
    }
}

- (IBAction)flipCard:(UITapGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    if (indexPath) {
        NSInteger deckIndex = [self.deckIndicesOfVisibleCards[indexPath.item] integerValue];
        [self.game flipCardAtIndex:deckIndex];
        [self updateUI];
        self.gameResult.score = self.game.score;
    }
}


- (NSArray *)facedUpCards
{
    NSMutableArray *cards = [NSMutableArray array];
    for (NSNumber *index in self.deckIndicesOfVisibleCards) {
        Card *card = [self.game cardAtIndex:[index integerValue]];
        if (!card.isUnplayable && card.isFaceUp) {
            [cards addObject:index];
        }
    }
    
    return cards;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return collectionView == self.collectionView ? [self.deckIndicesOfVisibleCards count] : [[self facedUpCards] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Card" forIndexPath:indexPath];
    NSInteger deckIndex = 0;
    if (collectionView == self.collectionView) {
        deckIndex = [self.deckIndicesOfVisibleCards[indexPath.item] integerValue];
    }
    else {
        deckIndex = [[self facedUpCards][indexPath.item] integerValue];
    }

    Card *card = [self.game cardAtIndex:deckIndex];
    [self updateCell:cell usingCard:card animated:NO];
    return cell;
}

#pragma mark CardMatchingGameDelegate

- (void)cardMatchingGame:(CardMatchingGame *)game cards:(NSArray *)cards didMatchWithScore:(NSInteger)score
{
    NSMutableAttributedString *text;
    if (score > 0) {
        text = [[NSMutableAttributedString alloc] initWithString:@"Matched "];
        [text appendAttributedString:[self cards:cards joinedByString:@", "]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" for %d point", score]]];
        
        if (self.removesUnplayableCards) {
            [self hideUnplayableCards:cards];
        }
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

#pragma mark - Helpers

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

#pragma mark - Abstract methods

// Implement in subclass
- (NSUInteger)startingCardCount
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}
- (CardMatchingGameMode)gameMode
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}
- (Deck *)createDeck
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (NSString *)gameTypeName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card animated:(BOOL)animated
{
    [self doesNotRecognizeSelector:_cmd];
}
- (NSAttributedString *)attributedStringForCard:(Card *)card
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (BOOL)removesUnplayableCards
{
    return NO;
}
@end
