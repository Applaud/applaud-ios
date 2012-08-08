//
//  PollOptionCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PollOptionCell : UITableViewCell

@property (strong, nonatomic) UILabel *percentageLabel;
@property (strong, nonatomic) UIView *barGraphView;

- (void)showResult;

@end
