//
//  ErrorViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/28/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface ErrorViewController : UIViewController

@property (nonatomic, strong) UILabel *errorTitle;
@property (nonatomic, strong) UILabel *errorBody;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;

// These are error title and body definitions for each
// error code.

// ERROR_NO_CONNECTION
#define tERROR_NO_CONNECTION @"Apatapa couldn't connect to the internet."
#define bERROR_NO_CONNECTION @"Check that you have service in this area, or try connecting to a Wifi network."

// ERROR_BAD_LOGIN
#define tERROR_BAD_LOGIN @"Apatapa couldn't log you in."
#define bERROR_BAD_LOGIN @"To register with Apatapa, visit http://apatapa.com/accounts/member/. If you're sure you already have an account, you can recover your password at http://apatapa.com/accounts/password/reset/."

// ERROR_SERVER_ERROR
#define tERROR_SERVER_ERROR @"Apatapa had an error."
#define bERROR_SERVER_ERROR @"Something went wrong on our server. We'll have everything up and running as soon as possible."

// ERROR_NO_LOCATION
#define tERROR_NO_LOCATION @"Location Services Disabled."
#define bERROR_NO_LOCATION @"It seems that you have disabled location services for Apatapa. Since the service this app provides to you requires your location, please enable it through your Settings app under \"Location Services\"."

@end
