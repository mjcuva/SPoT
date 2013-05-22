//
//  ImageViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"
#import "Cacher.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleItem;
@property (strong, nonatomic) UIImageView *imageView;

// Image to show when no other image is loaded
@property (weak, nonatomic) IBOutlet UIImageView *noImageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation ImageViewController

// resets the image whenever the URL changes

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void)setTitle:(NSString *)title{
    super.title = title;
    [self.titleItem setTitle:title];
}

// fetches the data from the URL
// turns it into an image
// adjusts the scroll view's content size to fit the image
// sets the image as the image view's image

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        [self.activityIndicator startAnimating];
        
        dispatch_queue_t loadImageQueue = dispatch_queue_create("load image", NULL);
        dispatch_async(loadImageQueue, ^{
            
            // Get if image in cache, returns nil if not
            UIImage *image = [Cacher getImageWithTitle:self.title];
            
            if(!image){
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//                [NSThread sleepForTimeInterval:2];
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
                image = [[UIImage alloc] initWithData:imageData];
                
                // Prevent Null image from being saved
                if(image){
                    [Cacher addImageToCacheWithData:imageData andTitle:self.title];
                }
            }
                
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.scrollView.zoomScale = 1.0;
                    self.scrollView.contentSize = image.size;
                    self.imageView.image = image;
                    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                    self.noImageView.hidden = YES;
                    [self resizeImage];
                }
                [self.activityIndicator stopAnimating];
            });
        });
    }
}

- (void)resizeImage{
    if ((self.imageView.bounds.size.width)&&(self.imageView.bounds.size.height)) {
        CGFloat widthRatio  = self.scrollView.bounds.size.width  / self.imageView.bounds.size.width;
        CGFloat heightRatio = self.scrollView.bounds.size.height / self.imageView.bounds.size.height;
        self.scrollView.zoomScale = (widthRatio > heightRatio) ? widthRatio : heightRatio;
    }
}

- (void)viewDidLayoutSubviews{
    [self resizeImage];
}

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

// returns the view which will be zoomed when the user pinches
// in this case, it is the image view, obviously
// (there are no other subviews of the scroll view in its content area)

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

// add the image view to the scroll view's content area
// setup zooming by setting min and max zoom scale
//   and setting self to be the scroll view's delegate
// resets the image in case URL was set before outlets (e.g. scroll view) were set

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.4;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];

    self.titleItem.title = self.title; // Outlets not set in PrepareForSegue: Need to also set title here
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    [self resizeRectAnimated:NO];
}

@end
