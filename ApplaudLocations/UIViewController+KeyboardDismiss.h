//
//  UIViewController+KeyboardDismiss.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KeyboardDismiss)

- (void)initForKeyboardDismissal;
- (void)userTappedAway;

@end
