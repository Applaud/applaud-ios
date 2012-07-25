//
//  EmployeeBioCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/24/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"

@interface EmployeeBioCell : UITableViewCell

@property (strong, nonatomic) UILabel *bioLabel;
@property (strong, nonatomic) Employee *employee;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier employee:(Employee *)employee;
- (void)toggleBio;

@end
