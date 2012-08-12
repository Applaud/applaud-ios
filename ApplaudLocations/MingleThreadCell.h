//
//  MingleThreadCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Thread.h"

@class MingleListViewController;

@interface MingleThreadCell : UITableViewCell

@property (nonatomic, strong) Thread *thread;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *postsLabel;
@property (nonatomic, strong) UILabel *upvotesLabel;
@property (nonatomic, strong) UILabel *downvotesLabel;
@property (nonatomic, strong) UILabel *updownLabel;
@property (nonatomic, strong) UISegmentedControl *ratingWidget;
@property (nonatomic, strong) UITapGestureRecognizer *downRateRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *upRateRecognizer;
@property (nonatomic, strong) UIView *downRateView;
@property (nonatomic, strong) UIView *upRateView;
@property (nonatomic, weak) MingleListViewController *mlvc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier thread:(Thread*)thread;

@end
