//
//  NFViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessLocationsTracker.h"
#import "NFItemViewController.h"
#import "NFItem.h"
#import "UIImage+Scale.h"

@class AppDelegate;

@interface NFViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableDictionary *cellHeights;
}

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *newsFeeds;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
-(void)getNewsFeeds;
@end
