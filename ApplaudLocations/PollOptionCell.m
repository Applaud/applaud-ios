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
        
        _barGraphView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                 self.frame.size.height/4.0f,
                                                                 0,
                                                                 self.frame.size.height/2.0f)];
        self.barGraphView.backgroundColor = [UIColor clearColor];
        [self.barGraphView setHidden:YES];
        [self.contentView addSubview:self.barGraphView];
        [self.contentView sendSubviewToBack:self.barGraphView];
        
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.font = [UIFont boldSystemFontOfSize:OPTION_TEXT_SIZE];
        
        // Colors for rakings
        rankingColors = [NSArray arrayWithObjects:
                         [UIColor colorWithRed:0.2588f
                                         green:0.6863f
                                          blue:0.0f
                                         alpha:1.0f],
                         [UIColor colorWithRed:0.933f
                                         green:0.345f
                                          blue:0
                                         alpha:1.0f],
                         [UIColor colorWithRed:0.0353f
                                         green:0.3255f
                                          blue:0.8980f
                                         alpha:1.0f],
                         [UIColor colorWithRed:1.0f
                                         green:0.9922f
                                          blue:0.0f
                                         alpha:1.0f],
                         [UIColor colorWithRed:0.6627f
                                         green:0
                                          blue:0.8078f
                                         alpha:1.0f],
                         [UIColor colorWithRed:1.0f
                                         green:0.0f
                                          blue:0.0f
                                         alpha:1.0f],
                         nil];
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setBarGraphColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setBarGraphColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:NO];
}

- (void)setValue:(double)value {
    _value = value;
    
    // Set percentage label
    self.percentageLabel.text = [NSString stringWithFormat:@"%2.2f%%",100.0f * self.value];
    [self layoutSubviews];
}

- (void)setRank:(int)rank {
    _rank = rank;
    [self setBarGraphColor];
}

- (void)setTotalRanks:(int)totalRanks {
    _totalRanks = totalRanks;
    [self setBarGraphColor];
}

- (void)setBarGraphColor {
    if ( self.rank == 1 )
        self.barGraphView.backgroundColor = rankingColors[0];
    else if ( self.rank == self.totalRanks )
        self.barGraphView.backgroundColor = rankingColors[rankingColors.count-1];
    else if ( self.totalRanks <= rankingColors.count ) {
        int whichColor = (self.rank / (double)self.totalRanks) * rankingColors.count;
        self.barGraphView.backgroundColor = rankingColors[MIN(MAX(1,whichColor),rankingColors.count-2)];
    }
    else {
        self.barGraphView.backgroundColor = rankingColors[rankingColors.count/2];
    }
}

- (void)showResult {
    [self.percentageLabel setHidden:NO];
    
    self.barGraphView.frame = CGRectMake(0,
                                         self.frame.size.height/4.0f,
                                         0,
                                         self.frame.size.height/2.0f);
    [self.barGraphView setHidden:NO];
    
    [UIView beginAnimations:@"BarGraphAnimation" context:nil];
    [UIView setAnimationDuration:0.5f];
    self.barGraphView.frame = CGRectMake(0,
                                         self.frame.size.height/4.0f,
                                         self.value * (CELL_WIDTH - 2*CELL_MARGIN),
                                         self.frame.size.height/2.0f);
    [UIView commitAnimations];
}

@end
