//
//  PhotoZoomViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/2/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PhotoZoomViewController.h"

@interface PhotoZoomViewController ()

@end

@implementation PhotoZoomViewController

- (id)initWithImage:(UIImage *)image;
{
    if (self = [super init]) {
        _image = image;
        _scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.contentSize = CGSizeMake(320, 436 - 44 - 64);
        _scrollView.delegate = self;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(160 - image.size.width/2,
                                                                   240 - image.size.height/2 - 44,
                                                                   image.size.width,
                                                                   image.size.height)];
        _imageView.image = image;
        [_scrollView addSubview:_imageView];
        self.view = _scrollView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 6.0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma UIScrollView delegate methods

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
