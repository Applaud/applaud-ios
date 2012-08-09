//
//  PollOptionCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PollOptionCell.h"
#import "PollOptionDisplayConstants.h"

@implementation PollOptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];

        _percentageLabel = [[UILabel alloc] init];
        self.percentageLabel.backgroundColor = [UIColor clearColor];
        self.percentageLabel.font = [UIFont systemFontOfSize:RESULT_TEXT_SIZE];
        [self.percentageLabel setHidden:YES];
        
        self.accessoryView = [[UIView alloc] init];
        self.accessoryView.backgroundColor = [UIColor clearColor];
        [self.accessoryView addSubview:self.percentageLabel];
        
        _barGraphView = [[UIView alloc] initWithFrame:CGRectZero];
        self.barGraphView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.barGraphView];
        [self.contentView sendSubviewToBack:self.barGraphView];
        
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.font = [UIFont boldSystemFontOfSize:OPTION_TEXT_SIZE];
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
    
    [self.percentageLabel sizeToFit];
    self.percentageLabel.frame = CGRectMake(0,
                                            ACCESSORY_SIZE/2.0f - self.percentageLabel.frame.size.height/2.0f,
                                            ACCESSORY_SIZE,
                                            self.percentageLabel.frame.size.height);
    self.barGraphView.frame = CGRectMake(0,
                                         self.frame.size.height/4.0f,
                                         MAX(5.0f, self.value * (CELL_WIDTH - 2*CELL_MARGIN)),
                                         self.frame.size.height/2.0f);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.barGraphView.backgroundColor = [UIColor colorWithHue:self.value/3.0f saturation:0.6f brightness:0.8f alpha:0.5f];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.barGraphView.backgroundColor = [UIColor colorWithHue:self.value/3.0f saturation:0.6f brightness:0.8f alpha:0.5f];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:NO];
}

- (void)setValue:(double)value {
    _value = value;
    
    // Set percentage label
    self.percentageLabel.text = [NSString stringWithFormat:@"%2.2f%%",100.0f * self.value];
    
    // Set bar graph
    self.barGraphView.backgroundColor = [UIColor colorWithHue:self.value/3.0f saturation:0.6f brightness:0.8f alpha:0.5f];
    [self layoutSubviews];
}

- (void)showResult {
    [self.percentageLabel setHidden:NO];
}

@end
