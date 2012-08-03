//
//  PhotoZoomViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/2/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoZoomViewController : UIViewController <UIScrollViewDelegate>

//@property (nonatomic, strong) UInavi
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

-(id)initWithImage:(UIImage *)image;
@end
