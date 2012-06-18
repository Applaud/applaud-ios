//
//  FirstTimeNavigatorViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/18/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstTimeNavigatorViewController : UIViewController

// This is persistent throughout the application. It controls all of the view controllers.
@property (nonatomic, strong) UITabBarController *tabBarController;

@end
