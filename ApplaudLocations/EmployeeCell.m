//
//  EmployeeCell.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/31/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "EmployeeCell.h"

@implementation EmployeeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) { }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(CELL_MARGIN, CELL_MARGIN,
                                      50,50);
}

@end
