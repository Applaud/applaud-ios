//
//  MinglePostViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Thread.h"
@class MingleListViewController;

@interface MinglePostViewController : UITableViewController <UITextFieldDelegate> {
    BOOL keyboardIsShown;
    NSMutableDictionary *cellMap;
}
- (id) initWithStyle:(UITableViewStyle)style thread:(Thread *) thread;

@property (nonatomic, strong) NSMutableArray *threadPosts;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *toolbarWidgets;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) Thread *thread;
@property (nonatomic, weak) MingleListViewController *parent;

@end
