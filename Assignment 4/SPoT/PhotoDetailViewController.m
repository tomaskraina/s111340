//
//  PhotoDetailViewController.m
//  SPoT
//
//  Created by Tom K on 4/10/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "FlickrFetcher.h"

@interface PhotoDetailViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (strong, nonatomic) NSDictionary *photoInfo;
@property (weak, nonatomic) UIImageView *photoImageView;
@property (nonatomic, getter = isZoomed) BOOL zoomed;
@end

@implementation PhotoDetailViewController

- (void)setUpWithPhotoInfo:(NSDictionary *)photoInfo
{
    self.photoInfo = photoInfo;
}

#pragma mark - Properties

- (void)setPhotoImageView:(UIImageView *)imageView
{
    if (_photoImageView != imageView) {
        _photoImageView = imageView;
        
        [self.photoScrollView addSubview:imageView];
        self.photoScrollView.contentSize = imageView.bounds.size;
        self.photoScrollView.minimumZoomScale = [self calculateMinimumZoomScaleForImageView:imageView];
        [self.photoScrollView zoomToRect:self.photoImageView.bounds animated:NO];
        
        self.zoomed = NO;
    }
}

#pragma mark - UIViewController life cycle

- (void)viewDidLayoutSubviews
{
    if (self.photoImageView) {
        self.photoScrollView.minimumZoomScale = [self calculateMinimumZoomScaleForImageView:self.photoImageView];
        
        if (!self.isZoomed) {
            [self.photoScrollView zoomToRect:self.photoImageView.bounds animated:YES];
        }

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSURL *photoUrl = [FlickrFetcher urlForPhoto:self.photoInfo format:FlickrPhotoFormatLarge];
    NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
    UIImage *photoImage = [UIImage imageWithData:photoData];
    self.photoImageView = [[UIImageView alloc] initWithImage:photoImage];
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

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    self.zoomed = scale != scrollView.minimumZoomScale;
}

#pragma mark - convinience methods

- (CGFloat)calculateMinimumZoomScaleForImageView:(UIImageView *)imageView
{
    CGFloat xZoomScale = self.photoScrollView.bounds.size.width / imageView.bounds.size.width;
    CGFloat yZoomScale = self.photoScrollView.bounds.size.height / imageView.bounds.size.height;
    
    return MIN(xZoomScale, yZoomScale);
}

@end
