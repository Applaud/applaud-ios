//
//  PollsViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

enum SORT_METHODS {
    SORT_NEWEST = 0,
    SORT_POPULAR = 1,
    SORT_LIKED = 2
};

@interface PollsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableDictionary *cellMap;
    
    NSMutableArray *pollsSortedNewest;
    NSMutableArray *pollsSortedLiked;
    NSMutableArray *pollsSortedPopular;
    
    // What method used to sort the polls
    int sortMethod;
    
    // Used to show selected rating momentarily
    NSTimer *timer;
}

@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *polls;

- (void)getPolls;

@end
