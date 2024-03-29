//
//  MingleThreadCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Thread.h"
#import "ApatapaRatingWidget.h"

@class MingleListViewController;

@interface MingleThreadCell : UITableViewCell <RatingWidgetDelegate>

@property (nonatomic, strong) Thread *thread;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *postsLabel;
@property (nonatomic, strong) ApatapaRatingWidget *ratingWidget;
@property (nonatomic, weak) MingleListViewController *mlvc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier thread:(Thread*)thread;

@end
