//
//  PollsViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ApatapaRatingWidget.h"

@interface PollsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, RatingWidgetDelegate> {
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
