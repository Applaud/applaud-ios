//
//  SignInViewController.h
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginRegistrationConstants.h"
#import "AppDelegate.h"
#import "ConnectionManager.h"
#import <string.h>
#import <QuartzCore/QuartzCore.h>

@interface SignInViewController : UIViewController<UITextViewDelegate>

@property (nonatomic, strong) UITextView *username;
@property (strong, nonatomic) NSTimer *usernameTimer;

@property (nonatomic, strong) UITextView *password;
@property (strong, nonatomic) NSTimer *passwordTimer;

@property (strong, nonatomic) UIButton *signInButton;
@property (strong, nonatomic) CAGradientLayer *signInButtonLayer;

@property (nonatomic, strong) UINavigationBar *navBar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, weak) UIWindow *window;

@end
