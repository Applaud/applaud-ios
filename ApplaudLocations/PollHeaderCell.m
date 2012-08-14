//
//  PollHeaderCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/14/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PollHeaderCell.h"
#import "PollOptionDisplayConstants.h"
#import "PollsViewController.h"

@implementation PollHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier poll:(Poll *)poll
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.poll = poll;
        self.ratingWidget = [[ApatapaRatingWidget alloc] initWithFrame:CGRectZero upvotesCount:self.poll.upvotes];
        if ( self.poll.my_rating )
            self.ratingWidget.enabled = NO;
        self.textLabel.font = [UIFont boldSystemFontOfSize:POLL_QUESTION_TEXT_SIZE];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.text = self.poll.title;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.ratingWidget];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize constraintSize, labelSize;
    constraintSize = CGSizeMake(CELL_WIDTH
                                - 2*CELL_MARGIN
                                - 2*CELL_PADDING
                                - POLL_RATING_WIDTH
                                - POLL_RATING_PADDING, 400);
    
    self.ratingWidget.frame = CGRectMake(CELL_WIDTH - POLL_RATING_PADDING - POLL_RATING_WIDTH - CELL_PADDING - CELL_MARGIN,
                                         CELL_PADDING,
                                         POLL_RATING_WIDTH,
                                         32);
    
    // Keep user's rating visible until we download polls again (looks neater this way)
    if ( [self.poll my_rating] )
        self.ratingWidget.enabled = NO;
    else
        self.ratingWidget.delegate = self;

    labelSize = [self.poll.title sizeWithFont:[UIFont boldSystemFontOfSize:POLL_QUESTION_TEXT_SIZE]
                            constrainedToSize:constraintSize
                                lineBreakMode:UILineBreakModeWordWrap];
    self.textLabel.frame = CGRectMake(CELL_PADDING, CELL_PADDING, constraintSize.width, labelSize.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)upRateWithWidget:(ApatapaRatingWidget *)widget {
    [self.parent upRatePoll:self.poll];
    self.ratingWidget.enabled = NO;
}

@end
