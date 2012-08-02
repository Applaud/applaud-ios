//
//  NFItemTableViewCell.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/1/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFItemTableViewCell.h"
#import "NFDisplayConstants.h"

@implementation NFItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier newsfeed:(NFItem *)newsfeed
{
    __weak NFItemTableViewCell *weakSelf = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self = weakSelf;
    if (self) {
        _newsfeed = newsfeed;
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        self.titleLabel.text = self.newsfeed.title;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        self.bodyLabel.text = self.newsfeed.body;
        self.bodyLabel.font = [UIFont systemFontOfSize:TEASER_SIZE];
        self.bodyLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [self.imageView setImageWithURL:self.newsfeed.imageURL
                       placeholderImage:nil
                                success:^(UIImage *image) {
                                    [weakSelf setNeedsDisplay];
                                    [weakSelf setNeedsLayout];
                                }
                                failure:^(NSError *error) {}];
        
        [self.containerView addSubview:self.titleLabel];
        [self.containerView addSubview:self.bodyLabel];
        [self.contentView addSubview:self.containerView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = [self.containerView bounds];
    if(!self.editing) {
        CGFloat maxTitleWidth, titleLeftMargin;
        if(![self.newsfeed.imageURL.absoluteString isEqualToString:@""]) {
            self.imageView.frame = CGRectMake(CELL_PADDING,
                                              CELL_PADDING,
                                              DETAIL_IMAGE_SIZE,
                                              DETAIL_IMAGE_SIZE);
            maxTitleWidth = contentRect.size.width - 2*CELL_PADDING - DETAIL_IMAGE_SIZE - CELL_ELEMENT_PADDING;
            titleLeftMargin = CELL_ELEMENT_PADDING + DETAIL_IMAGE_SIZE + CELL_PADDING;
        }
        else {
            maxTitleWidth = contentRect.size.width - 2*CELL_PADDING;
            titleLeftMargin = CELL_PADDING;
        }
        CGSize titleSize = [self.newsfeed.title sizeWithFont:self.titleLabel.font
                                           constrainedToSize:CGSizeMake(maxTitleWidth, 400)
                                               lineBreakMode:UILineBreakModeWordWrap];
        self.titleLabel.frame = CGRectMake(titleLeftMargin,
                                           CELL_PADDING,
                                           maxTitleWidth,
                                           titleSize.height);
        CGSize bodySize = [self.newsfeed.body sizeWithFont:self.bodyLabel.font
                                         constrainedToSize:CGSizeMake(self.contentView.frame.size.width - 2*CELL_PADDING,
                                                                      400)
                                             lineBreakMode:UILineBreakModeWordWrap];
        NSLog(@"body height: %f", bodySize.height);
        self.bodyLabel.frame = CGRectMake(CELL_PADDING,
                                          CELL_PADDING
                                          + MAX(self.imageView.frame.size.height,
                                                self.titleLabel.frame.size.height)
                                          + CELL_ELEMENT_PADDING,
                                          contentRect.size.width - 2*CELL_PADDING,
                                          bodySize.height);
        NSLog(@"different cell height: %f", MAX(titleSize.height, DETAIL_IMAGE_SIZE) + bodySize.height + 2*CELL_PADDING + CELL_ELEMENT_PADDING);
        NSLog(@"origin y: %f", self.bodyLabel.frame.origin.y);
    }
    [self.containerView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    _height = 2*CELL_PADDING + 2*CELL_ELEMENT_PADDING + MAX(self.imageView.frame.size.height,
                                                            self.titleLabel.frame.size.height) + self.bodyLabel.frame.size.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
