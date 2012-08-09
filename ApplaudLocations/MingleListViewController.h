//
//  MingleListViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Thread.h"

@interface MingleListViewController : UITableViewController {
    // What method used to sort the threads
    int sortMethod;
    
    // Pre-sorted lists of threads
    NSMutableArray *threadsSortedNewest;
    NSMutableArray *threadsSortedPopular;
    NSMutableArray *threadsSortedLiked;
}

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong, readwrite) UINavigationController *navigationController;
@property (nonatomic, strong) NSMutableArray *threads;

@end
