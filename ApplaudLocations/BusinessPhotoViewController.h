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

@class AppDelegate;

@interface BusinessPhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *businessPhotos;
@property (nonatomic, strong) UIButton *cameraButton;
@end
