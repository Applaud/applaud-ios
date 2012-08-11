//
//  EmployeeListViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/16/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EmployeeCell.h"

@class AppDelegate;

@interface EmployeeListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
    BOOL keyboardIsShown;
}

@property (weak, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *employeeArray;
@property (strong, nonatomic) NSMutableArray *employeeControllers;
@property (weak, nonatomic) UINavigationController *navigationController;

// Fetches the list of employees from the business
- (void)getEmployees;
- (void)notificationReceived:(NSNotification *)notification;
@end
