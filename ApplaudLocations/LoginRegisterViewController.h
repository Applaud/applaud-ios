//
//  LoginRegisterViewController.h
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ConnectionManager.h"
#import "AppDelegate.h"
#import "SignInViewController.h"
#import "RegistrationViewController.h"

@interface LoginRegisterViewController : UIViewController

@property (nonatomic, strong) UILabel *apatapaTitle;
@property (nonatomic, strong) UIButton *signIn;
@property (nonatomic, strong) CAGradientLayer *signInLayer;
@property (nonatomic, strong) UIButton *createAccount;
@property (nonatomic, strong) CAGradientLayer *createAccountLayer;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) CAGradientLayer *backgroundGradient;

@end
