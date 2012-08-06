//
//  PollAccordionCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PollAccordionCell.h"

@implementation PollAccordionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
