//
//  PhotoDetailViewController.m
//  SPoT
//
//  Created by Tom K on 4/10/13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotos.h"
#import "FileCache.h"

@interface PhotoDetailViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (strong, nonatomic) NSDictionary *photoInfo;
@property (weak, nonatomic, readonly) UIImageView *photoImageView;
@property (nonatomic, getter = isZoomed) BOOL zoomed;
@property (nonatomic, getter = isLoading) BOOL loading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation PhotoDetailViewController

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) {
        [items removeObject:_splitViewBarButtonItem];
    }
    
    if (barButtonItem) {
        [items insertObject:barButtonItem atIndex:0];
    }
    
    self.toolbar.items = items;
    _splitViewBarButtonItem = barButtonItem;
}

- (void)setUpWithPhotoInfo:(NSDictionary *)photoInfo
{
    self.photoInfo = photoInfo;
    [RecentPhotos addPhoto:photoInfo];
}

#pragma mark - Properties

- (void)setLoading:(BOOL)loading
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:loading];
    if (loading) {
        [self.activityIndicator startAnimating];
    }
    else {
        [self.activityIndicator stopAnimating];
    }
}

#define IMAGE_VIEW_TAG 1234

- (UIImageView *)photoImageView
{
    return (UIImageView *)[self.photoScrollView viewWithTag:IMAGE_VIEW_TAG];
}

- (void)addPhotoImageViewToScrollView:(UIImageView *)imageView
{    
    imageView.tag = IMAGE_VIEW_TAG;
    [self.photoScrollView addSubview:imageView];
    self.photoScrollView.contentSize = imageView.bounds.size;
    self.photoScrollView.minimumZoomScale = [self calculateMinimumZoomScaleForImageView:imageView];
    self.photoScrollView.maximumZoomScale = 2.0;
    [self.photoScrollView zoomToRect:imageView.bounds animated:NO];
    
    self.zoomed = NO;
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
    
    if (!self.photoImageView && self.photoInfo) {
        BOOL original = [UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale] > 1024 || [UIScreen mainScreen].bounds.size.height * [[UIScreen mainScreen] scale] > 1024; // 1024x1024 size of large photo
        [self loadPhoto:self.photoInfo format: original ? FlickrPhotoFormatOriginal : FlickrPhotoFormatLarge];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.splitViewBarButtonItem && ![self.toolbar.items containsObject:self.splitViewBarButtonItem]) {
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [items insertObject:self.splitViewBarButtonItem atIndex:0];
        self.toolbar.items = items;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Downloading

- (void)loadPhoto:(NSDictionary *)flickrPhoto format:(FlickrPhotoFormat)format
{
    self.loading = YES;
    
    dispatch_queue_t q = dispatch_queue_create("photo downloading", NULL);
    dispatch_async(q, ^{
        
        NSData *photoData = [[FileCache sharedCache] dataForKey:flickrPhoto[FLICKR_PHOTO_ID]];
        if (!photoData) {
            NSURL *photoUrl = [FlickrFetcher urlForPhoto:self.photoInfo format:FlickrPhotoFormatLarge];
            photoData = [NSData dataWithContentsOfURL:photoUrl];
            [[FileCache sharedCache] setData:photoData forKey:flickrPhoto[FLICKR_PHOTO_ID]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loading = NO;
            if (!self.photoImageView) {
                UIImage *photoImage = [UIImage imageWithData:photoData scale:[[UIScreen mainScreen] scale]];
                [self addPhotoImageViewToScrollView:[[UIImageView alloc] initWithImage:photoImage]];
            }
        });
    });
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
    
    return MIN( MIN(1,xZoomScale), MIN(1,yZoomScale));
}

@end
