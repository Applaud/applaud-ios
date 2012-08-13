//
//  MinglePostCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "MinglePostCell.h"
#import "MingleDisplayConstants.h"
#import "MinglePostViewController.h"
#import "ApatapaDateFormatter.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation MinglePostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier threadPost:(ThreadPost *)post
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.post = post;
        
        self.textLabel.font = [UIFont systemFontOfSize:BODY_TEXT_SIZE];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel = [UILabel new];
        self.dateLabel.font = [UIFont systemFontOfSize:DATE_SIZE];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel = [UILabel new];
        self.usernameLabel.font = [UIFont boldSystemFontOfSize:USER_SIZE];
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        
        self.ratingWidget = [ApatapaRatingWidget new];
        self.ratingWidget.delegate = self;
        
        self.profilePicture = [UIImageView new];
        
        [self initContent];
        
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.profilePicture];
        [self.contentView addSubview:self.ratingWidget];
    }
    return self;
}

- (void)initContent {
    
    __weak MinglePostCell *weakSelf = self;
    [self.profilePicture setImageWithURL:self.post.user.profilePictureURL
                        placeholderImage:nil
                                 success:^(UIImage *image) {
                                     [weakSelf setNeedsDisplay];
                                     [weakSelf setNeedsLayout];
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Something went wrong: %@",error);
                                 }];
    
    self.textLabel.text = self.post.body;
    self.dateLabel.text = [ApatapaDateFormatter stringFromDate:self.post.date_created];
    self.usernameLabel.text = self.post.user.name;
    
    self.ratingWidget.upvotesCount = self.post.upvotes;
    if ( self.post.my_rating )
        self.ratingWidget.enabled = NO;
}

- (void)setPost:(ThreadPost *)post {
    _post = post;
    [self initContent];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.profilePicture.frame = CGRectMake(CELL_PADDING, CELL_PADDING, IMAGE_SIZE, IMAGE_SIZE);
    self.ratingWidget.frame = CGRectMake(CELL_WIDTH - CELL_MARGIN - CELL_PADDING - MINGLE_RATING_WIDTH, CELL_PADDING,
                                         MINGLE_RATING_WIDTH, 24.0f);
    self.usernameLabel.frame = CGRectMake(CELL_PADDING + IMAGE_SIZE + CELL_ELEMENT_PADDING,
                                          CELL_PADDING,
                                          CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING - IMAGE_SIZE - CELL_ELEMENT_PADDING - MINGLE_RATING_PADDING,
                                          20.0f);
    self.dateLabel.frame = CGRectMake(self.usernameLabel.frame.origin.x,
                                      self.usernameLabel.frame.origin.y + self.usernameLabel.frame.size.height + CELL_ELEMENT_PADDING,
                                      self.usernameLabel.frame.size.width,
                                      20.0f);
    CGSize bodyContraint = CGSizeMake(self.usernameLabel.frame.size.width, 400);
    CGSize bodySize = [self.post.body sizeWithFont:[UIFont systemFontOfSize:BODY_TEXT_SIZE]
                                 constrainedToSize:bodyContraint
                                     lineBreakMode:UILineBreakModeWordWrap];
    self.textLabel.frame = CGRectMake(self.dateLabel.frame.origin.x,
                                      self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + CELL_ELEMENT_PADDING,
                                      self.usernameLabel.frame.size.width,
                                      bodySize.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)upRateWithWidget:(ApatapaRatingWidget *)widget {
    [self.mpvc giveRating:1 toThreadPostWithId:self.post.threadpost_id];
    self.ratingWidget.enabled = NO;
}

@end
