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
- (void)downRate;

@end

@interface ApatapaRatingWidget : UIView

@property (nonatomic, strong) UILabel *upvotesLabel;
@property (nonatomic, strong) UILabel *downvotesLabel;
@property (nonatomic, strong) UILabel *updownLabel;
@property (nonatomic, strong) UISegmentedControl *ratingWidget;
@property (nonatomic, strong) UITapGestureRecognizer *downRateRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *upRateRecognizer;
@property (nonatomic, strong) UIView *downRateView;
@property (nonatomic, strong) UIView *upRateView;
@property (nonatomic, weak) id<RatingWidgetDelegate> delegate;

@end
