//
//  ReminderViewController.h
//  MindTheCheckOut
//
//  Created by Tom K on 5/7/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reminder;

@interface ReminderViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) Reminder *reminder;

@end
