//
//  NewMingleThreadViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MingleListViewController;

@interface NewMingleThreadViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) MingleListViewController *parent;

@end
