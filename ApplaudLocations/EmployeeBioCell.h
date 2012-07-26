//
//  EmployeeBioCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/24/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

/* Determining the height of EmployeeBioCell in a ViewController:

 if ( bioCellExpanded ) {
 CGSize bioContentLabelSize = [self.employee.bio sizeWithFont:[UIFont systemFontOfSize:CONTENT_SIZE]
 constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 2*CELL_PADDING, 200)
 lineBreakMode:UILineBreakModeWordWrap];
 return 2*CELL_PADDING + CELL_ELEMENT_PADDING + bioContentLabelSize.height + TITLE_LABEL_HEIGHT;
 }
 return 2*CELL_PADDING + TITLE_LABEL_HEIGHT;
 
 */

#import <UIKit/UIKit.h>
#import "Employee.h"

@interface EmployeeBioCell : UITableViewCell

@property (strong, nonatomic) UILabel *bioLabel;
@property (strong, nonatomic) Employee *employee;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier employee:(Employee *)employee;
- (void)toggleBio;

@end
