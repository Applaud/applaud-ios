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
        CGSize textSize = [self.comment.text sizeWithFont:[UIFont systemFontOfSize:COMMENT_SIZE]
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
        [self.contentView addSubview:self.commentTextView];
        self.nameLabel = [[UILabel alloc]
                          initWithFrame:CGRectMake(CELL_PADDING,
                                                   CELL_PADDING +
                                                   self.commentTextView.frame.size.height +
                                                   ELEMENT_MARGIN,
                                                   self.contentView.frame.size.width - 2*CELL_PADDING,
                                                   NAME_HEIGHT)];
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",
                               self.comment.firstName, self.comment.lastName];
        [self.contentView addSubview:self.nameLabel];
        self.commentTextView.backgroundColor = self.contentView.backgroundColor;
        self.nameLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setComment:(Comment *)comment {
    _comment = comment;
    CGSize textSize = [self.comment.text sizeWithFont:[UIFont systemFontOfSize:COMMENT_SIZE]
                                    constrainedToSize:CGSizeMake(self.contentView.frame.size.width -
                                                                 2*CELL_PADDING,
                                                                 1000)
                                        lineBreakMode:UILineBreakModeWordWrap];
    self.commentTextView.frame = CGRectMake(CELL_PADDING,
                                            CELL_PADDING,
                                            textSize.width,
                                            textSize.height);
    self.commentTextView.text = self.comment.text;
    self.nameLabel.frame = CGRectMake(CELL_PADDING,
                                      CELL_PADDING +
                                      self.commentTextView.frame.size.height +
                                      ELEMENT_MARGIN,
                                      self.contentView.frame.size.width - 2*CELL_PADDING,
                                      NAME_HEIGHT);
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.comment.firstName,
                           self.comment.lastName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
