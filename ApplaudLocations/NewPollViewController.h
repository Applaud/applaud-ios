//
//  NewPollViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PollSubmitCancelCell.h"

@class PollsViewController;

@interface NewPollViewController : UITableViewController <UITextFieldDelegate, SubmitCancelDelegate, UIAlertViewDelegate> {
    BOOL first_time;
}

@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, strong) NSString *pollTitle;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, weak) PollsViewController *pollsViewController;
//@property (nonatomic, weak) UINavigationController *navigationController;

@end
