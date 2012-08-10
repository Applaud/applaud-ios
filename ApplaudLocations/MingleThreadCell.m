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
                              [UIImage imageNamed:@"downrate"],
                              [UIImage imageNamed:@"uprate"], nil]];
        
        [self.contentView addSubview:self.userLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.postsLabel];
        [self.contentView addSubview:self.ratingWidget];
        [self.contentView addSubview:self.upvotesLabel];
        [self.contentView addSubview:self.updownLabel];
        [self.contentView addSubview:self.downvotesLabel];
        
        [self initContent];
    }
    return self;
}

- (void)initContent {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MM/dd/yyyy";
    
    self.textLabel.text = self.thread.title;
    self.userLabel.text = self.thread.user_creator.username;
    self.dateLabel.text = [formatter stringFromDate:self.thread.date_created];
    NSString *comment = self.thread.threadPosts.count == 1? @"post" : @"posts";
    self.postsLabel.text = [NSString stringWithFormat:@"%d %@",self.thread.threadPosts.count, comment];
    
    self.upvotesLabel.text = [NSString stringWithFormat:@"+%d",self.thread.upvotes];
    self.downvotesLabel.text = [NSString stringWithFormat:@"-%d",self.thread.downvotes];
    
    if ( self.thread.my_rating == -1 ) {
        self.ratingWidget.selectedSegmentIndex = 0;
        self.ratingWidget.userInteractionEnabled = NO;
    } else if ( self.thread.my_rating == 1 ) {
        self.ratingWidget.selectedSegmentIndex = 1;
        self.ratingWidget.userInteractionEnabled = NO;
    } else {
        [self.ratingWidget addTarget:self action:@selector(rateThread:) forControlEvents:UIControlEventValueChanged];
    }
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
        self.ratingWidget.frame = CGRectMake(CELL_WIDTH - CELL_MARGIN - MINGLE_RATING_WIDTH - 2*CELL_PADDING,
                                             CELL_PADDING, MINGLE_RATING_WIDTH, 32.0f);
        
        // Ratings labels
        self.updownLabel.frame = CGRectMake(self.ratingWidget.frame.origin.x + MINGLE_RATING_WIDTH/2,
                                            self.ratingWidget.frame.origin.y + self.ratingWidget.frame.size.height + CELL_ELEMENT_PADDING,
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

- (IBAction)rateThread:(id)sender {
    UISegmentedControl *ratingWidget = (UISegmentedControl*)sender;
    
    [self.mlvc giveRating:ratingWidget.selectedSegmentIndex
           toThreadWithId:self.thread.thread_id];
    
    // Disable rating now
    ratingWidget.userInteractionEnabled = NO;
}

@end
