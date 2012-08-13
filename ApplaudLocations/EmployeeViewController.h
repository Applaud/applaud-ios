//
//  EmployeeViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"
#import "BusinessLocationsTracker.h"
@class AppDelegate;

@interface EmployeeViewController : UITableViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    BOOL bioCellExpanded;       // Whether the "bio" cell is currently expanded or not
    BOOL keyboardIsShown;       // Whether the keyboard is currently showing
    CGRect selectedTextRect;    // The rect of the currently active textfield
    CGPoint previousOffset;     // The point where the scrollview was scrolled to before text editing
    
    NSMutableArray *widgetList;
    
    NSMutableDictionary *sliderLabelTable;
    NSMutableDictionary *clearButtonTable;
    NSMutableDictionary *sliderTable;
    NSMutableDictionary *activityTable;
}

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) Employee *employee;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *bioContentLabel;    // Displays the bio
@property (strong, nonatomic) UIView *profileView;         // Contains image, name, title, bio as subviews
@property (strong, nonatomic) NSMutableDictionary *ratingDimensions;
@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UITableView *tableView;

- (id)initWithStyle:(UITableViewStyle)style employee:(Employee *)e;
- (IBAction)submitButtonPressed:(UIButton *)sender;

@end
