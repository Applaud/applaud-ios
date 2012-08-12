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

@interface SignInViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, weak) UIWindow *window;

@end
