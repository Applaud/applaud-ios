//
//  PhotoCommentCell.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PhotoCommentCell.h"

@implementation PhotoCommentCell

- (id)initWithComment:(Comment *)comment
                style:(UITableViewCellStyle)style
      reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _comment = comment;
        self.ratingWidget = [[ApatapaRatingWidget alloc] initWithFrame:CGRectMake(CELL_WIDTH - CELL_MARGIN - CELL_PADDING - MINGLE_RATING_WIDTH, CELL_PADDING,
                                                                                  MINGLE_RATING_WIDTH, 24.0f)
                                                               upvotesCount:_comment.votes];
        self.ratingWidget.delegate = self;
        [self checkCanVote];
        CGSize textSize = [self.comment.text sizeWithFont:[UIFont systemFontOfSize:BODY_TEXT_SIZE]
                                        constrainedToSize:CGSizeMake(self.contentView.frame.size.width -
                                                                     2*CELL_PADDING,
                                                                     1000)
                                            lineBreakMode:UILineBreakModeWordWrap];
        self.commentTextView = [[UITextView alloc]
                                initWithFrame:CGRectMake(CELL_PADDING,
                                                         CELL_PADDING,
                                                         textSize.width,
                                                         textSize.height)];
        self.commentTextView.text = self.comment.text;
        self.commentTextView.editable = NO;
        self.commentTextView.scrollEnabled = NO;
        self.commentTextView.font = [UIFont systemFontOfSize:BODY_TEXT_SIZE];
        [self.contentView addSubview:self.commentTextView];
        self.nameLabel = [[UILabel alloc]
                          initWithFrame:CGRectMake(CELL_PADDING,
                                                   CELL_PADDING,
                                                   CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING,
                                                   20.0f)];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:USER_SIZE];
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",
                               self.comment.firstName, self.comment.lastName];
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.frame.origin.x,
                                                                   self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + CELL_ELEMENT_PADDING,
                                                                   self.nameLabel.frame.size.width,
                                                                   20.0f)];
        self.dateLabel.font = [UIFont systemFontOfSize:DATE_SIZE];
        self.dateLabel.text = [ApatapaDateFormatter stringFromDate:self.comment.date_created];
        [self.contentView addSubview:self.ratingWidget];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.nameLabel];
        self.commentTextView.backgroundColor = self.contentView.backgroundColor;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setComment:(Comment *)comment {
    _comment = comment;
    CGSize bodySize = [self.comment.text sizeWithFont:[UIFont systemFontOfSize:BODY_TEXT_SIZE]
                                    constrainedToSize:CGSizeMake(self.nameLabel.frame.size.width, 400)
                                        lineBreakMode:UILineBreakModeWordWrap];
    self.commentTextView.frame = CGRectMake(CELL_PADDING/2,
                                            self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height,
                                            self.nameLabel.frame.size.width,
                                            bodySize.height);
    self.commentTextView.text = self.comment.text;
    self.nameLabel.frame = CGRectMake(CELL_PADDING,
                                      CELL_PADDING,
                                      CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING,
                                      20.0f);

    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.comment.firstName,
                           self.comment.lastName];
    [self checkCanVote];
}

-(void)checkCanVote {
    NSDictionary *params = @{@"id": @(self.comment.comment_id), @"type": @"models.Comment"};
    [ConnectionManager serverRequest:@"POST" withParams:params
                                 url:CHECK_VOTE_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                NSString *response = [[NSString alloc]
                                                      initWithData:d
                                                      encoding:NSUTF8StringEncoding];
                                if([response isEqualToString:@"yes"]) {
                                    self.ratingWidget.enabled = YES;
                                }
                                else {
                                    self.ratingWidget.enabled = NO;
                                }
                            }];
}

-(void)upRateWithWidget:(ApatapaRatingWidget *)widget {
    NSDictionary *params = @{@"id": @(self.comment.comment_id)};
    [ConnectionManager serverRequest:@"POST" withParams:params
                                 url:COMMENT_VOTE_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                self.ratingWidget.enabled = NO;
                                NSLog(@"enabled %d", self.ratingWidget.enabled);
                            }];
}
@end
