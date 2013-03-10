//
//  SetGameViewController.m
//  Matchismo
//
//  Created by Tom on 05.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCardDeck.h"
#import "SetCard.h"

@interface SetGameViewController ()

@end

@implementation SetGameViewController

- (CardMatchingGameMode)gameMode
{
    return CardMatchingGameModeMatch3Cards;
}

- (Deck *)deck
{
    return [[SetCardDeck alloc] init];
}

- (NSString *)gameTypeName
{
    static NSString *gameTypeName = @"Set Game";
    return gameTypeName;
}

- (UIColor *)colorFromSetCard:(SetCard *)card
{
    if ([card.color isEqual:SetCardRedColor]) {
        return [UIColor redColor];
    }
    else if ([card.color isEqual:SetCardGreenColor]) {
        return [UIColor greenColor];
    }
    else if ([card.color isEqual:SetCardPurpleColor]) {
        return [UIColor purpleColor];
    }
    
    return nil;
}

- (float)alphaFromSetCard:(SetCard *)card
{
    if ([card.shading isEqual:SetCardOpenShading]) {
        return 0;
    }
    else if ([card.shading isEqual:SetCardStrippedShading]) {
        return .2;
    }
    else {
        return 1;
    }
}

- (NSAttributedString *)attributedStringForCard:(SetCard *)card
{    
    UIColor *fillColor = [[self colorFromSetCard:card] colorWithAlphaComponent:[self alphaFromSetCard:card]];

    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:15.],
                                 NSForegroundColorAttributeName: fillColor,
                                 NSStrokeColorAttributeName: [self colorFromSetCard:card],
                                 NSStrokeWidthAttributeName: @-10
                                 };
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[card contents] attributes:attributes];
    
    return attributedString;
}

- (void)configureCardButton:(UIButton *)cardButton forCard:(SetCard *)card
{
    if (![card isKindOfClass:[SetCard class]]) {
        return;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringForCard:card]];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [attributedString addAttributes:@{NSParagraphStyleAttributeName: paragraphStyle} range:NSMakeRange(0, [attributedString length])];
    
    [cardButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    [cardButton setAttributedTitle:attributedString forState:UIControlStateSelected];

    cardButton.titleLabel.numberOfLines = 0; // Important to get the title on multiple lines
    cardButton.contentEdgeInsets = UIEdgeInsetsMake(2.0, 5.0, 2.0, 5.0);
    cardButton.backgroundColor = card.isFaceUp ? [UIColor yellowColor] : [UIColor whiteColor];
    cardButton.selected = card.isFaceUp;
    cardButton.hidden = card.isUnplayable;
}

//- (void)gameDidReset
//{
//
//}
//
//- (void)cardDidFlip
//{
//
//}

@end
