//
//  UIViewController+KeyboardDismiss.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "UIViewController+KeyboardDismiss.h"

@implementation UIViewController (keyboardDismiss)

- (void)initForKeyboardDismissal {
    UITapGestureRecognizer *tapAwayRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedAway)];
    tapAwayRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapAwayRecognizer];
}

- (void)userTappedAway {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
