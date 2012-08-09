//
//  NewMingleThreadViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubmitCancelCell.h"

@class MingleListViewController;

@interface NewMingleThreadViewController : UITableViewController <UITextFieldDelegate, SubmitCancelDelegate>

@property (weak, nonatomic) MingleListViewController *parent;

@end
