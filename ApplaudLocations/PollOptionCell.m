//
//  PollOptionCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PollOptionCell.h"
#import "PollOptionDisplayConstants.h"

@implementation PollOptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.percentageLabel = [[UILabel alloc] init];
        self.percentageLabel.backgroundColor = [UIColor clearColor];
        self.accessoryView = [[UIView alloc] init];
        self.accessoryView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        //TODO: initialize and configure the barGraphView.
        
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.font = [UIFont boldSystemFontOfSize:OPTION_TEXT_SIZE];
        self.percentageLabel.font = [UIFont systemFontOfSize:RESULT_TEXT_SIZE];
        [self.percentageLabel setHidden:YES];
        [self.accessoryView addSubview:self.percentageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(CELL_MARGIN,
                                        0,
                                        CELL_WIDTH - 2*CELL_MARGIN - ACCESSORY_SIZE,
                                        self.frame.size.height);
    
    CGSize constraintSize = CGSizeMake(self.contentView.frame.size.width - 2*CELL_PADDING, 400);
    CGSize labelSize = [self.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:OPTION_TEXT_SIZE]
                                       constrainedToSize:constraintSize
                                           lineBreakMode:UILineBreakModeWordWrap];
    self.textLabel.frame = CGRectMake(CELL_PADDING, CELL_PADDING, self.contentView.frame.size.width - 2*CELL_PADDING, labelSize.height);
    self.accessoryView.frame = CGRectMake(CELL_WIDTH - CELL_MARGIN - ACCESSORY_SIZE,
                                          0,
                                          ACCESSORY_SIZE,
                                          ACCESSORY_SIZE);
    self.percentageLabel.frame = CGRectMake(0, 0, ACCESSORY_SIZE, ACCESSORY_SIZE);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showResult {
    [self.percentageLabel setHidden:NO];
}

@end
