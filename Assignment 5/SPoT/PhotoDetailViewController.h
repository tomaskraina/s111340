//
//  PhotoDetailViewController.h
//  SPoT
//
//  Created by Tom K on 4/10/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailViewController : UIViewController
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;
//- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem;
- (void)setUpWithPhotoInfo:(NSDictionary *)photoInfo;

@end
