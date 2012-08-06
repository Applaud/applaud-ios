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

@interface RegistrationViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *email;
@property (strong, nonatomic) UITextField *firstName;
@property (strong, nonatomic) UITextField *lastName;
@property (strong, nonatomic) UITextField *password;

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, weak) UIWindow *window;

@end
