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

#define PHOTO_BORDER 20.0f

@interface PhotoZoomViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic) int index;

-(id)initWithPhotos:(NSMutableArray *)photo index:(int)index;
@end
