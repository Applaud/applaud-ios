//
//  MasterViewController.h
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MapViewController.h"

@interface MasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *locationsArray;
@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) UIWindow *window;

// So we can look at our program state, including whether or not this was the first time launching.
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// This is persistent throughout the application. It controls all of the view controllers.
@property (nonatomic, strong) UITabBarController *tabBarController;

@end
