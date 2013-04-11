//
//  PhotoDetailViewController.m
//  SPoT
//
//  Created by Tom K on 4/10/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "FlickrFetcher.h"

@interface PhotoDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (strong, nonatomic) NSDictionary *photoInfo;
@end

@implementation PhotoDetailViewController

- (void)setUpWithPhotoInfo:(NSDictionary *)photoInfo
{
    self.photoInfo = photoInfo;
}

#pragma mark - UIViewController life cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSURL *photoUrl = [FlickrFetcher urlForPhoto:self.photoInfo format:FlickrPhotoFormatLarge];
    NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
    UIImage *photoImage = [UIImage imageWithData:photoData];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:photoImage];

    [self.photoScrollView addSubview:imageView];
    self.photoScrollView.contentSize = imageView.bounds.size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
