//
//  EmployeeListViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/16/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface EmployeeListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *employeeArray;
@property (strong, nonatomic) NSMutableArray *employeeControllers;
@property (weak, nonatomic) UINavigationController *navigationController;

// Fetches the list of employees from the business
- (void)getEmployees;
- (void)notificationReceived:(NSNotification *)notification;
@end
