//
//  MinglePostViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MinglePostViewController : UITableViewController <UITextFieldDelegate> {
    BOOL keyboardIsShown;
    NSMutableDictionary *cellMap;
}

@property (nonatomic, strong) NSMutableArray *threadPosts;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *toolbarWidgets;
@property (nonatomic, strong) UITextField *textField;

@end
