//
//  EmployeeViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"

#define RATING_FIELD_HEIGHT 70
#define RATING_FIELDS_BEGIN 300

@interface EmployeeViewController : UIViewController {
    Employee *employee;
}


@property (nonatomic, strong) Employee *employee;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITextView *bioField;

- (id)initWithEmployee:(Employee *)e;

@end
