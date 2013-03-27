//
//  SetCardView.m
//  Matchismo
//
//  Created by Tom on 24.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "SetCardView.h"

@implementation SetCardView

- (void)drawRect:(CGRect)rect
{    
    // Draw card background (rounded rect)
    [self drawBackground];
    
    // Draw symbols
    for (NSUInteger i = 1; i <= self.number; i++) {

        CGPoint center = CGPointMake(self.bounds.size.width / 2., self.bounds.size.height / (CGFloat)(self.number + 1));
        center.y *= i;
        
        [self drawSymbol:self.symbol atPoint:center];
    }
}

#define CARD_CORNER_RADIUS_RATIO 0.15

- (void)drawBackground
{
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) * CARD_CORNER_RADIUS_RATIO;
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    [backgroundPath addClip]; //prevents filling corners, i.e. sharp corners not included in roundedRect
    
    UIColor *backgroundColor = self.isSelected ? [UIColor colorWithRed:1 green:1 blue:.9 alpha:1] : [UIColor whiteColor];
    [backgroundColor setFill];
    UIRectFill(self.bounds);
    
    [[UIColor blackColor] setStroke];
    [backgroundPath stroke];
}

- (void)drawSymbol:(SetCardViewSymbol)symbol atPoint:(CGPoint)center
{
    [self pushContextAndTranlateForSymbolAtPoint:center];
    
    switch (symbol) {
        case SetCardViewSymbolDiamond:
            [self drawDiamondAtPoint:center];
            break;
        case SetCardViewSymbolOval:
            [self drawOvalAtPoint:center];
            break;
        case SetCardViewSymbolSquiggle:
            [self drawSquiggleAtPoint:center];
            break;
        default:
            break;
    }
    
    [self popContext];
}

#define SYMBOL_WIDTH_RATIO 0.7
#define SYMBOL_HEIGHT_RATIO 0.2

- (void)pushContextAndTranlateForSymbolAtPoint:(CGPoint)center
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    
    CGContextTranslateCTM(c, center.x - (SYMBOL_WIDTH_RATIO * self.bounds.size.width / 2.), center.y - (SYMBOL_HEIGHT_RATIO * self.bounds.size.height / 2.) );
}

- (void)popContext
{
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}


- (void)drawDiamondAtPoint:(CGPoint)center
{
    CGPoint startPoint = CGPointMake(0, (SYMBOL_HEIGHT_RATIO * self.bounds.size.height / 2.));
    UIBezierPath *diamondPath = [UIBezierPath bezierPath];
    [diamondPath moveToPoint:startPoint];
    [diamondPath addLineToPoint:CGPointMake((SYMBOL_WIDTH_RATIO * self.bounds.size.width / 2.), 0)];
    [diamondPath addLineToPoint:CGPointMake(SYMBOL_WIDTH_RATIO * self.bounds.size.width, (SYMBOL_HEIGHT_RATIO * self.bounds.size.height / 2.))];
    [diamondPath addLineToPoint:CGPointMake((SYMBOL_WIDTH_RATIO * self.bounds.size.width / 2.), SYMBOL_HEIGHT_RATIO * self.bounds.size.height)];
    [diamondPath closePath];
    
    [self colorPath:diamondPath];
}

- (void)drawOvalAtPoint:(CGPoint)center
{
    CGRect rect = CGRectMake(0, 0, SYMBOL_WIDTH_RATIO * self.bounds.size.width, SYMBOL_HEIGHT_RATIO * self.bounds.size.height);
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [self colorPath:ovalPath];
}

- (void)drawSquiggleAtPoint:(CGPoint)center
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startPoint = CGPointMake(0, self.bounds.size.height * SYMBOL_HEIGHT_RATIO * 0.7);
    [path moveToPoint:startPoint];
    
    CGPoint controlPoint1 = CGPointMake(0, - (self.bounds.size.height * SYMBOL_HEIGHT_RATIO * 0.75));
    CGPoint controlPoint2 = CGPointMake(self.bounds.size.width * SYMBOL_WIDTH_RATIO * 0.6, self.bounds.size.height * SYMBOL_HEIGHT_RATIO * 0.6);
    CGPoint endPoint1 = CGPointMake(self.bounds.size.width * SYMBOL_WIDTH_RATIO * 0.8, 0);
    [path addCurveToPoint:endPoint1 controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
    CGPoint controlPoint3 = CGPointMake(self.bounds.size.width * SYMBOL_WIDTH_RATIO * 0.95, - (self.bounds.size.height * SYMBOL_HEIGHT_RATIO * 0.2));
    CGPoint endPoint2 = CGPointMake(self.bounds.size.width * SYMBOL_WIDTH_RATIO, self.bounds.size.height * SYMBOL_HEIGHT_RATIO * .3);
    [path addQuadCurveToPoint:endPoint2 controlPoint:controlPoint3];

    CGPoint controlPoint4 = CGPointMake(self.bounds.size.width * SYMBOL_WIDTH_RATIO, (self.bounds.size.height * SYMBOL_HEIGHT_RATIO * 1.75));
    CGPoint controlPoint5 = CGPointMake(self.bounds.size.width * SYMBOL_WIDTH_RATIO * 0.4, self.bounds.size.height * SYMBOL_HEIGHT_RATIO * 0.4);
    CGPoint endPoint3 = CGPointMake(self.bounds.size.width * SYMBOL_WIDTH_RATIO * 0.2, self.bounds.size.height * SYMBOL_HEIGHT_RATIO);
    [path addCurveToPoint:endPoint3 controlPoint1:controlPoint4 controlPoint2:controlPoint5];
    
    CGPoint controlPoint6 = CGPointMake(self.bounds.size.width * SYMBOL_WIDTH_RATIO * 0.05, self.bounds.size.height * SYMBOL_HEIGHT_RATIO * 1.2);
    [path addQuadCurveToPoint:startPoint controlPoint:controlPoint6];

    [path closePath];
    
    [self colorPath:path];
}

- (UIColor *)UIColor
{
    return [[self class] colorFromColor:self.color];
}

#define NO_OF_STRIPES 8
#define STRIPES_LINE_WIDTH .7

- (void)addStrippedShadingToPath:(UIBezierPath *)shape
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (NSUInteger i = 1; i <= NO_OF_STRIPES ; i++) {
        CGFloat xOffset = self.bounds.size.width * SYMBOL_WIDTH_RATIO / (NO_OF_STRIPES + 1.) * (CGFloat)i;
        [path moveToPoint:CGPointMake(xOffset, .0)];
        [path addLineToPoint:CGPointMake(xOffset, self.bounds.size.height * SYMBOL_HEIGHT_RATIO)];
    }
    
    [[self UIColor] setStroke];
    [path setLineWidth:STRIPES_LINE_WIDTH];
    [path stroke];
}

#define STROKE_LINE_WIDTH 2

- (void)colorPath:(UIBezierPath *)path
{
    UIColor *color = [self UIColor];
    [path setLineWidth:STROKE_LINE_WIDTH];
    [path addClip];
    
    switch (self.shading) {
        case SetCardViewShadingStripped:
            [self addStrippedShadingToPath:path];
        case SetCardViewShadingOpen:
            [color setStroke];
            [path stroke];
            break;
            
        case SetCardViewShadingSolid:
            [color setFill];
            [path fill];
            break;
            
        default:
            break;
    }
}

#pragma mark - Properties

- (void)setColor:(SetCardViewColor)color
{
    _color = color;
    [self setNeedsDisplay];
}
- (void)setNumber:(NSUInteger)number
{
    _number = number;
    [self setNeedsDisplay];
}
- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self setNeedsDisplay];
}
- (void)setShading:(SetCardViewShading)shading
{
    _shading = shading;
    [self setNeedsDisplay];
}
- (void)setSymbol:(SetCardViewSymbol)symbol
{
    _symbol = symbol;
    [self setNeedsDisplay];
}

#pragma mark - Class methods

+ (UIColor *)colorFromColor:(SetCardViewColor)color
{
    UIColor *uicolor;
    switch (color) {
        case SetCardViewColorGreen:
            uicolor = [UIColor greenColor];
            break;
        case SetCardViewColorPurple:
            uicolor = [UIColor purpleColor];
            break;
        case SetCardViewColorRed:
            uicolor = [UIColor redColor];
            break;
            
        default:
            break;
    }
    
    return uicolor;
}

@end
