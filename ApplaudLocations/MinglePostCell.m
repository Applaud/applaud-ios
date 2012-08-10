//
//  MinglePostCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "MinglePostCell.h"
#import "MingleDisplayConstants.h"

@implementation MinglePostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier threadPost:(ThreadPost *)post
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.post = post;
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MM/dd/yyyy";
        
        self.textLabel.text = self.post.body;
        self.textLabel.font = [UIFont systemFontOfSize:BODY_TEXT_SIZE];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel = [UILabel new];
        self.dateLabel.text = [formatter stringFromDate:self.post.date_created];
        self.dateLabel.font = [UIFont systemFontOfSize:DATE_SIZE];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel = [UILabel new];
        self.usernameLabel.text = self.post.user.username;
        self.usernameLabel.font = [UIFont boldSystemFontOfSize:USER_SIZE];
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        self.profilePicture = [[UIImageView alloc] initWithImage:self.post.user.profilePicture];
        self.ratingWidget = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:[UIImage imageNamed:@"uprate"]]];
        [self.ratingWidget addTarget:self action:@selector(ratePost:) forControlEvents:UIControlEventValueChanged];
        
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.profilePicture];
        [self.contentView addSubview:self.ratingWidget];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.profilePicture.frame = CGRectMake(CELL_PADDING, CELL_PADDING, IMAGE_SIZE, IMAGE_SIZE);
    self.ratingWidget.frame = CGRectMake(CELL_WIDTH - 2*CELL_MARGIN - CELL_PADDING - MINGLE_RATING_WIDTH/2,
                                         CELL_PADDING,
                                         MINGLE_RATING_WIDTH/2,
                                         32.0f);
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

- (IBAction)ratePost:(id)sender {
    // rate the post
}

@end
