//
//  MingleThreadCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "MingleThreadCell.h"
#import "MingleDisplayConstants.h"
#import "ConnectionManager.h"
#import "MingleListViewController.h"
#import "ApatapaDateFormatter.h"

@implementation MingleThreadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier thread:(Thread *)thread
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.thread = thread;
        
        // Set up cell properties
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        self.userLabel = [[UILabel alloc] init];
        self.userLabel.font = [UIFont systemFontOfSize:USER_SIZE];
        self.dateLabel = [UILabel new];
        self.dateLabel.font = [UIFont systemFontOfSize:DATE_SIZE];
        self.postsLabel = [UILabel new];
        self.postsLabel.font = [UIFont systemFontOfSize:POSTS_SIZE];

        self.ratingWidget = [ApatapaRatingWidget new];
        self.ratingWidget.delegate = self;
        
        [self.contentView addSubview:self.userLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.postsLabel];
        [self.contentView addSubview:self.ratingWidget];
        
        [self initContent];
    }
    return self;
}

- (void)initContent {
    self.textLabel.text = self.thread.title;
    self.userLabel.text = self.thread.user_creator.name;
    self.dateLabel.text = [ApatapaDateFormatter stringFromDate:self.thread.date_created];
    NSString *comment = self.thread.threadPosts.count == 1? @"post" : @"posts";
    self.postsLabel.text = [NSString stringWithFormat:@"%d %@",self.thread.threadPosts.count, comment];
    
    self.ratingWidget.upvotesCount = self.thread.upvotes;
    
    if ( self.thread.my_rating )
        self.ratingWidget.enabled = NO;
}

- (void)setThread:(Thread *)thread {
    _thread = thread;
    [self initContent];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ( ! self.editing ){
        // Thread title
        CGSize titleConstrant = CGSizeMake(CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING - MINGLE_RATING_WIDTH - MINGLE_RATING_PADDING, 400);
        CGSize titleSize = [self.thread.title sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]
                                         constrainedToSize:titleConstrant
                                             lineBreakMode:UILineBreakModeWordWrap];
        self.textLabel.frame = CGRectMake(CELL_PADDING, CELL_PADDING, titleConstrant.width, titleSize.height);
        
        // Rating widget
        self.ratingWidget.frame = CGRectMake(CELL_WIDTH - CELL_MARGIN - CELL_PADDING - MINGLE_RATING_WIDTH,
                                             CELL_PADDING,
                                             MINGLE_RATING_WIDTH,
                                             60.0f);
                                               
        // User label
        self.userLabel.frame = CGRectMake(CELL_PADDING,
                                          self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 3*CELL_ELEMENT_PADDING,
                                          100.0f, DATE_AND_USER_HEIGHT);
        
        // Date label
        self.dateLabel.frame = CGRectMake(100.0f + CELL_ELEMENT_PADDING,
                                          self.userLabel.frame.origin.y,
                                          100.0f, DATE_AND_USER_HEIGHT);
        
        // posts label
        self.postsLabel.frame = CGRectMake(CELL_PADDING, self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height,
                                           200.0f, 20.0f);
        
    }
}

- (void)upRateWithWidget:(ApatapaRatingWidget *)widget {
    [self.mlvc giveRating:1
           toThreadWithId:self.thread.thread_id];
    self.ratingWidget.enabled = NO;
}

@end
