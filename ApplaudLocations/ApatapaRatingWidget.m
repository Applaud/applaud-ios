//
//  ApatapaRatingWidget.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ApatapaRatingWidget.h"

#define RATING_TEXT_SIZE 10.0f
#define RATING_WIDGET_WIDTH 48.0f
#define RATING_WIDGET_HEIGHT 24.0f

@implementation ApatapaRatingWidget

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.updownLabel = [UILabel new];
        self.updownLabel.text = @"/";
        self.updownLabel.font = [UIFont systemFontOfSize:RATING_TEXT_SIZE];
        self.downvotesLabel = [UILabel new];
        self.downvotesLabel.font = [UIFont systemFontOfSize:RATING_TEXT_SIZE];
        self.downvotesLabel.textColor = [UIColor redColor];
        self.upvotesLabel = [UILabel new];
        self.upvotesLabel.font = [UIFont systemFontOfSize:RATING_TEXT_SIZE];
        self.upvotesLabel.textColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0];
        
        // Rating widget
        self.ratingWidget = [[UISegmentedControl alloc] initWithItems:
                             [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"thumbsdown"],
                              [UIImage imageNamed:@"thumbsup"], nil]];
        self.upRateView = [UIView new];
        self.downRateView = [UIView new];
        self.downRateRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downRate)];
        self.upRateRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(upRate)];
        [self.upRateView addGestureRecognizer:self.upRateRecognizer];
        [self.downRateView addGestureRecognizer:self.downRateRecognizer];
        
        // Set up layout
        // Rating widget
        self.ratingWidget.frame = CGRectMake(0, 0,
                                             RATING_WIDGET_WIDTH, RATING_WIDGET_HEIGHT);
        self.downRateView.frame = CGRectMake(self.ratingWidget.frame.origin.x - 15.0f,
                                             self.ratingWidget.frame.origin.y - 15.0f,
                                             self.ratingWidget.frame.size.width/2 + 15.0f,
                                             self.ratingWidget.frame.size.height + 2*15.0f);
        self.upRateView.frame = CGRectMake(self.ratingWidget.frame.origin.x + self.ratingWidget.frame.size.width/2,
                                           self.ratingWidget.frame.origin.y - 15.0f,
                                           self.ratingWidget.frame.size.width/2 + 15.0f,
                                           self.ratingWidget.frame.size.height + 2*15.0f);
        
        // Ratings labels
        self.updownLabel.frame = CGRectMake(self.ratingWidget.frame.origin.x + RATING_WIDGET_WIDTH/2,
                                            self.ratingWidget.frame.origin.y + self.ratingWidget.frame.size.height + 5.0f,
                                            10.0f, 14.0f);
        [self.updownLabel sizeToFit];
        [self.upvotesLabel sizeToFit];
        self.upvotesLabel.frame = CGRectMake(self.updownLabel.frame.origin.x + self.updownLabel.frame.size.width + 5.0f,
                                             self.updownLabel.frame.origin.y,
                                             self.upvotesLabel.frame.size.width, self.upvotesLabel.frame.size.height);
        [self.downvotesLabel sizeToFit];
        self.downvotesLabel.frame = CGRectMake(self.updownLabel.frame.origin.x - self.downvotesLabel.frame.size.width - 5.0f,
                                               self.updownLabel.frame.origin.y,
                                               self.downvotesLabel.frame.size.width,
                                               self.downvotesLabel.frame.size.height);
        
        [self addSubview:self.updownLabel];
        [self addSubview:self.downvotesLabel];
        [self addSubview:self.upvotesLabel];
        [self addSubview:self.ratingWidget];
        [self addSubview:self.upRateView];
        [self addSubview:self.downRateView];
    }
    return self;
}

- (void)upRate {
    [self.delegate upRate];
}

- (void)downRate {
    [self.delegate downRate];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    self.ratingWidget.userInteractionEnabled = userInteractionEnabled;
}

- (IBAction)voteSelected:(id)sender {
    UISegmentedControl *sc = (UISegmentedControl*)sender;
    if ( 0 == sc.selectedSegmentIndex ) {
        [self.delegate downRate];
    } else if ( 1 == sc.selectedSegmentIndex ){
        [self.delegate upRate];
    }
}

@end
