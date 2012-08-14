//
//  PollOptionCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Poll.h"

@interface PollOptionCell : UITableViewCell {
    NSArray *rankingColors;
}

@property (nonatomic) double value;
@property (nonatomic) int rank;
@property (nonatomic) int totalRanks;
@property (strong, nonatomic, readonly) UILabel *percentageLabel;
@property (strong, nonatomic, readonly) UIView *barGraphView;

- (void)showResult;

@end
