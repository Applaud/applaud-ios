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
        CGSize textSize = [self.comment.text sizeWithFont:[UIFont systemFontOfSize:BODY_TEXT_SIZE]
                                        constrainedToSize:CGSizeMake(self.contentView.frame.size.width -
                                                                     2*CELL_PADDING,
                                                                     1000)
                                            lineBreakMode:UILineBreakModeWordWrap];
        NSLog(@"Text Size %f %f comment %@", textSize.width, textSize.height, comment.text);
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
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.nameLabel];
        self.commentTextView.backgroundColor = self.contentView.backgroundColor;
        self.nameLabel.backgroundColor = [UIColor clearColor];
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
