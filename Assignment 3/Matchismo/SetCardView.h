//
//  SetCardView.h
//  Matchismo
//
//  Created by Tom on 24.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SetCardViewSymbol) {
    SetCardViewSymbolDiamond,
    SetCardViewSymbolSquiggle,
    SetCardViewSymbolOval
};

typedef NS_ENUM(NSUInteger, SetCardViewShading) {
    SetCardViewShadingOpen,
    SetCardViewShadingStripped,
    SetCardViewShadingSolid
};

typedef NS_ENUM(NSUInteger, SetCardViewColor) {
    SetCardViewColorRed,
    SetCardViewColorPurple,
    SetCardViewColorGreen
};

@interface SetCardView : UIView

@property (nonatomic) NSUInteger number;
@property (nonatomic) SetCardViewSymbol symbol;
@property (nonatomic) SetCardViewShading shading;
@property (nonatomic) SetCardViewColor color;

@property (nonatomic, getter = isSelected) BOOL selected;

+ (UIColor *)colorFromColor:(SetCardViewColor)color;

@end
