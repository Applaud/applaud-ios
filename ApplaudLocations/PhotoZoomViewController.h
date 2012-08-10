//
//  PhotoZoomViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/2/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "BusinessPhoto.h"
#import "PhotoCommentViewController.h"
#import "AppDelegate.h"

#define BUTTON_MARGIN 5.0f
#define BUTTON_HEIGHT 30.0f
#define BUTTON_WIDTH 50.0f

@interface PhotoZoomViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BusinessPhoto *photo;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UINavigationBar *navBar;

-(id)initWithPhoto:(BusinessPhoto *)photo;
@end
