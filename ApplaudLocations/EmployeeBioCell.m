//
//  EmployeeBioCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/24/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "EmployeeBioCell.h"
#import "EmployeeDisplayConstants.h"

@implementation EmployeeBioCell

@synthesize employee = _employee;
@synthesize bioLabel = _bioLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier employee:(Employee *)employee
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.text = @"Bio";
        self.textLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        
        self.employee = employee;
        
        // The bio label (content). Starts out hidden.
        self.bioLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bioLabel.text = self.employee.bio;
        self.bioLabel.font = [UIFont systemFontOfSize:CONTENT_SIZE];
        self.bioLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.bioLabel.numberOfLines = 0;
        [self.bioLabel setHidden:YES];
        [self.contentView addSubview:self.bioLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellContentWidth = self.contentView.bounds.size.width - 2*CELL_PADDING;
    
    if (! self.isEditing ) {
        // Layout for "Bio" label
        [self.textLabel setFrame:CGRectMake(CELL_PADDING, CELL_PADDING, cellContentWidth, TITLE_LABEL_HEIGHT)];

        
        // Layout for bio content
        [self.bioLabel setFrame:CGRectMake(CELL_PADDING,
                                           self.textLabel.frame.origin.y
                                           + TITLE_LABEL_HEIGHT
                                           + CELL_ELEMENT_PADDING,
                                           cellContentWidth,
                                           [self.employee.bio sizeWithFont:[UIFont systemFontOfSize:CONTENT_SIZE]
                                                         constrainedToSize:CGSizeMake(cellContentWidth, 200)
                                                             lineBreakMode:UILineBreakModeWordWrap].height)];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Other Methods

/*
 * show/hide the bio
 */
- (void)toggleBio {
    [self.bioLabel setHidden:![self.bioLabel isHidden]];
}

@end
