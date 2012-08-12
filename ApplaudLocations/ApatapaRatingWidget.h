//
//  ApatapaRatingWidget.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RatingWidgetDelegate <NSObject>

@required
- (void)upRate;

@end

@interface ApatapaRatingWidget : UIView

@property (nonatomic) int upvotesCount;
@property (nonatomic, strong) UILabel *upvotesLabel;
@property (nonatomic, strong) UIButton *voteButton;
@property (nonatomic, strong) UITapGestureRecognizer *upRateRecognizer;
@property (nonatomic, weak) id<RatingWidgetDelegate> delegate;
@property (nonatomic) BOOL enabled;

- (id)initWithFrame:(CGRect)frame upvotesCount:(int)upvotesCount;

@end
