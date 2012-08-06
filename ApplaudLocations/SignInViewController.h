//
//  SignInViewController.h
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ConnectionManager.h"

@interface SignInViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, weak) UIWindow *window;

@end
