//
//  NewPollViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NewPollViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, strong) NSString *pollTitle;
@property (nonatomic, weak) AppDelegate *appDelegate;

@end
