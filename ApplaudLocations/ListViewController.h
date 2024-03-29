//
//  MasterViewController.h
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *locationsArray;
@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) UILabel *titleLabel;

@end
