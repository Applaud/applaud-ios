//
//  LoginRegisterViewController.h
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionManager.h"
#import "AppDelegate.h"
#import "SignInViewController.h"
#import "RegistrationViewController.h"

@interface LoginRegisterViewController : UIViewController

@property (nonatomic, strong) UIButton *signIn;
@property (nonatomic, strong) UIButton *createAccount;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) UIWindow *window;

@end
