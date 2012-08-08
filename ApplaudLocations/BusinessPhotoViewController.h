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
#define PHOTO_SIZE 70.0f
// 2*PHOTO_PADDING + PHOTOS_PER_LINE*PHOTO_SIZE + (PHOTOS_PER_LINE-1)*PHOTO_MARGIN = self.frame.size.width = 320
// 10 + PHOTOS_PER_LINE*PHOTO_SIZE + (PHOTOS_PER_LINE-1)*10 = 320
// PHOTOS_PER_LINE*PHOTO_SIZE + 10*(PHOTOS_PER_LINE-1) = 310
// 4*PHOTO_SIZE + 30 = 310
// 4*PHOTO_SIZE = 280
// PHOTO_SIZE = 70
#define PHOTOS_PER_LINE 4

@class AppDelegate;

@interface BusinessPhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *businessPhotos;
@property (nonatomic, strong) UIButton *cameraButton;

@end
