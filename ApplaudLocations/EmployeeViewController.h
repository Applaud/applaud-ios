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

@interface EmployeeViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) Employee *employee;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet UITextView *bioField;
@property (strong, nonatomic) NSMutableDictionary *ratingDimensions;
@property (weak, nonatomic) IBOutlet UIImageView *image;

- (id)initWithEmployee:(Employee *)e;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)submitButtonPressed:(UIButton *)sender;

@end
