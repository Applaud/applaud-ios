//
//  PollsViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PollsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableDictionary *percentageMap;
    NSMutableDictionary *totalsMap;
    NSMutableDictionary *cellMap;
}

@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *polls;

- (void)getPolls;

@end
