//
//  ApatapaRatingWidget.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ApatapaRatingWidget.h"

#define RATING_TEXT_SIZE 10.0f
#define RATING_WIDGET_WIDTH 24.0f
#define RATING_WIDGET_HEIGHT 24.0f

@implementation ApatapaRatingWidget

- (id)initWithFrame:(CGRect)frame upvotesCount:(int)upvotesCount
{
    self = [super initWithFrame:frame];
    if (self) {
        self.upvotesLabel = [UILabel new];
        self.upvotesLabel.font = [UIFont systemFontOfSize:RATING_TEXT_SIZE];
        self.upvotesLabel.textColor = [UIColor lightGrayColor];
        self.upvotesLabel.backgroundColor = [UIColor clearColor];
        
        // Rating widget
        self.voteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, RATING_WIDGET_WIDTH, RATING_WIDGET_HEIGHT)];
        [self.voteButton setImage:[UIImage imageNamed:@"thumbsup"] forState:UIControlStateNormal];
        [self.voteButton setImage:[UIImage imageNamed:@"thumbsup_disabled"] forState:UIControlStateDisabled];
        self.voteButton.adjustsImageWhenHighlighted = NO;
        self.upRateRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(upRate)];
        [self addGestureRecognizer:self.upRateRecognizer];
        [self.voteButton addTarget:self action:@selector(upRate) forControlEvents:UIControlEventTouchUpInside];

        self.upvotesCount = upvotesCount;
        
        [self addSubview:self.upvotesLabel];
        [self addSubview:self.voteButton];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame upvotesCount:0];
}

- (void)upRate {
    if(self.enabled) {
        [self.delegate upRateWithWidget:self];
        self.upvotesCount = self.upvotesCount + 1;
    }
}

- (void)setUpvotesCount:(int)upvotesCount {
    _upvotesCount = upvotesCount;
    self.upvotesLabel.text = [NSString stringWithFormat:@"+%d",self.upvotesCount];
    [self.upvotesLabel sizeToFit];
    self.upvotesLabel.frame = CGRectMake(self.voteButton.frame.origin.x + self.voteButton.frame.size.width,
                                         self.voteButton.frame.origin.y + self.voteButton.frame.size.height/2 - self.upvotesLabel.frame.size.height/2,
                                         self.upvotesLabel.frame.size.width, self.upvotesLabel.frame.size.height);
    [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)userInteractionEnabled {
    _enabled = userInteractionEnabled;
    self.voteButton.userInteractionEnabled = userInteractionEnabled;
    self.voteButton.enabled = NO;

}

@end
