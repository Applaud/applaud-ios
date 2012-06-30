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
#import "ApplaudProgramSettingsModel.h"
#import "AppDelegate.h"

@interface MasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *locationsArray;
@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, weak) AppDelegate *appDelegate;

// Program settings
@property (nonatomic, strong) ApplaudProgramSettingsModel *settings;

// This is persistent throughout the application. It controls all of the view controllers.
@property (nonatomic, strong) UITabBarController *tabBarController;

@end
