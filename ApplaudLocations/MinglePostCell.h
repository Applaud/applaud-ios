//
//  MinglePostCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadPost.h"
#import "ApatapaRatingWidget.h"

@class MinglePostViewController;

@interface MinglePostCell : UITableViewCell <RatingWidgetDelegate>

@property (nonatomic, strong) ThreadPost *post;
@property (nonatomic, strong) UIImageView *profilePicture;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) ApatapaRatingWidget *ratingWidget;
@property (nonatomic, weak) MinglePostViewController *mpvc;
//N.B. Body is in the textLabel property

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier threadPost:(ThreadPost*)post;

@end
