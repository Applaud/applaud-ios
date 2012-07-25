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

@interface EmployeeViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    BOOL bioCellExpanded;       // Whether the "bio" cell is currently expanded or not
    BOOL keyboardIsShown;       // Whether the keyboard is currently showing
    CGRect selectedTextRect;    // The rect of the currently active textfield
    CGPoint previousOffset;     // The point where the scrollview was scrolled to before text editing
}

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) Employee *employee;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSMutableDictionary *ratingDimensions;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (id)initWithEmployee:(Employee *)e;
- (IBAction)submitButtonPressed:(UIButton *)sender;

@end
