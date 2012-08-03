//
//  BusinessPhotoViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/23/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "BusinessPhoto.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "PhotoZoomViewController.h"

#define PHOTO_MARGIN 10.0f
#define PHOTO_PADDING 5.0f
#define PHOTO_SIZE 100.0f

@class AppDelegate;

@interface BusinessPhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *businessPhotos;
@property (nonatomic, strong) UIButton *cameraButton;

@end
