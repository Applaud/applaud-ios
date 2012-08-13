//
//  RegistrationViewController.h
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ConnectionManager.h"
#import "LoginRegistrationConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface RegistrationViewController : UIViewController<UITextViewDelegate>

@property (strong, nonatomic) UITextView *email;
@property (nonatomic) BOOL isEmailValid;
@property (strong, nonatomic) UIImageView *emailStatusImage;
@property (strong, nonatomic) NSTimer *emailTimer;

@property (strong, nonatomic) UITextView *firstName;
@property (strong, nonatomic) NSTimer *firstNameTimer;
@property (nonatomic) BOOL isFirstNameValid;

@property (strong, nonatomic) UITextView *lastName;

@property (strong, nonatomic) UITextView *password;
@property (nonatomic) BOOL isPasswordValid;
@property (strong, nonatomic) UIImageView *passwordStatusImage;
@property (strong, nonatomic) NSTimer *passwordTimer;

@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) CAGradientLayer *registerButtonLayer;

@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, weak) UIWindow *window;

@end
