//
//  NewPollViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SubmitCancelCell.h"

@class PollsViewController;

@interface NewPollViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, SubmitCancelDelegate, UIAlertViewDelegate> {
    BOOL first_time;
}

@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, strong) NSString *pollTitle;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, weak) PollsViewController *pollsViewController;

@end
