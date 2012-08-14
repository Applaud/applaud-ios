//
//  PollHeaderCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/14/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApatapaRatingWidget.h"
#import "Poll.h"

@class PollsViewController;

@interface PollHeaderCell : UITableViewCell <RatingWidgetDelegate>

@property (nonatomic, strong) ApatapaRatingWidget *ratingWidget;
@property (nonatomic, strong) Poll* poll;
@property (nonatomic, weak) PollsViewController *parent;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier poll:(Poll*)poll;

@end
