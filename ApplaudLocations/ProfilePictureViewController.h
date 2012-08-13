//
//  ProfilePictureViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "LoginRegistrationConstants.h"
#import "UIImage+ResizeNormalize.h"

@interface ProfilePictureViewController : UIViewController <UIImagePickerControllerDelegate,
                                                            UINavigationControllerDelegate>

@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UILabel *text;
@property (strong, nonatomic) UIButton *noPictureButton;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) UIImage *image;

-(id)initWithUsername:(NSString *)username password:(NSString *)password;
@end
