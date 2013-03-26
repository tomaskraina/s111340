//
//  SetCardCollectionViewCell.h
//  Matchismo
//
//  Created by Tom on 21.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetCardView.h"

@interface SetCardCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet SetCardView *setCardView;
@end
