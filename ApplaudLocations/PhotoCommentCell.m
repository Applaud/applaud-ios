//
//  PhotoCommentCell.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PhotoCommentCell.h"
#import "PhotoCommentViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation PhotoCommentCell

- (id)initWithComment:(Comment *)comment
                style:(UITableViewCellStyle)style
      reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"Init.....");
        _comment = comment;
//        self.ratingWidget = [[ApatapaRatingWidget alloc] initWithFrame:CGRectMake(CELL_WIDTH - CELL_MARGIN - CELL_PADDING - MINGLE_RATING_WIDTH, CELL_PADDING,
//                                                                                  MINGLE_RATING_WIDTH, 24.0f)
//                                                               upvotesCount:_comment.votes];
        self.textLabel.numberOfLines = 0;
        self.textLabel.font = [UIFont systemFontOfSize:BODY_TEXT_SIZE];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.ratingWidget = [[ApatapaRatingWidget alloc] init];
        self.ratingWidget.delegate = self;
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:USER_SIZE];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:DATE_SIZE];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.profilePicture = [[UIImageView alloc] init];
        
        // Adding the subviews to the cell
        [self.contentView addSubview:self.ratingWidget];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.profilePicture];
        
        [self initContent];
    }
    return self;
}

-(void)initContent{
   
    __weak PhotoCommentCell *weakSelf = self;
    [self.profilePicture setImageWithURL:self.comment.profilePictureURL
                        placeholderImage:nil
                                 success:^(UIImage *image) {
                                     [weakSelf setNeedsDisplay];
                                     [weakSelf setNeedsLayout];
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Something went wrong: %@",error);
                                 }];

    self.textLabel.text = self.comment.text;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.comment.firstName, self.comment.lastName];
    self.dateLabel.text = [ApatapaDateFormatter stringFromDate:self.comment.date_created];
    self.ratingWidget.upvotesCount = self.comment.votes;
    
    if ( self.comment.myRating )
        self.ratingWidget.enabled = NO;
}

-(void)setComment:(Comment *)comment{
    _comment = comment;
    [self initContent];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.profilePicture.frame = CGRectMake(CELL_PADDING, CELL_PADDING, IMAGE_SIZE, IMAGE_SIZE);
    self.ratingWidget.frame = CGRectMake(CELL_WIDTH - CELL_MARGIN - CELL_PADDING - MINGLE_RATING_WIDTH, CELL_PADDING,
                                         MINGLE_RATING_WIDTH, 24.0f);
    self.nameLabel.frame = CGRectMake(CELL_PADDING + IMAGE_SIZE + CELL_ELEMENT_PADDING,
                                          CELL_PADDING,
                                          CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING - IMAGE_SIZE - CELL_ELEMENT_PADDING - MINGLE_RATING_PADDING,
                                          20.0f);
    self.dateLabel.frame = CGRectMake(self.nameLabel.frame.origin.x,
                                      self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + CELL_ELEMENT_PADDING,
                                      self.nameLabel.frame.size.width,
                                      20.0f);
    
    CGSize bodyContraint = CGSizeMake(self.nameLabel.frame.size.width, 400);
    CGSize bodySize = [self.comment.text sizeWithFont:[UIFont systemFontOfSize:BODY_TEXT_SIZE]
                                 constrainedToSize:bodyContraint
                                     lineBreakMode:UILineBreakModeWordWrap];
    self.textLabel.frame = CGRectMake(self.dateLabel.frame.origin.x,
                                      self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + CELL_ELEMENT_PADDING,
                                      self.nameLabel.frame.size.width,
                                      bodySize.height);
}

-(void)upRateWithWidget:(ApatapaRatingWidget *)widget {
//    NSDictionary *params = @{@"id": @(self.comment.comment_id)};
//    [ConnectionManager serverRequest:@"POST" withParams:params
//                                 url:COMMENT_VOTE_URL
//                            callback:^(NSHTTPURLResponse *r, NSData *d) {
//                                self.ratingWidget.enabled = NO;
//                                self.comment.myRating = 1;
//                                NSLog(@"enabled %d", self.ratingWidget.enabled);
//                            }];
    [self.pcvc giveRatingToCommentWithId:self.comment.comment_id];
    self.ratingWidget.enabled = NO;
}
@end
