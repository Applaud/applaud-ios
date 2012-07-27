//
//  NFTableViewCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/24/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NFDisplayConstants.h"

@implementation NFTableViewCell

@synthesize titleLabel = _titleLabel;
@synthesize bodyLabel = _bodyLabel;
@synthesize newsfeed = _newsfeed;
@synthesize containerView = _containerView;
@synthesize height = _height;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier newsfeed:(NFItem *)newsfeed
{
    __weak NFTableViewCell *weakSelf = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self = weakSelf;
    if (self) {
        self.newsfeed = newsfeed;
        
        // Set up container view, where all subviews will go
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];

        // Set up title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.text = self.newsfeed.title;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
                                
        // Set up body teaser
        self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSString *bodyTeaserText = [newsfeed.body 
                                    substringToIndex:MIN(TEASER_LENGTH,
                                                         newsfeed.body.length-1)];
        bodyTeaserText = [NSString stringWithFormat:@"%@...",bodyTeaserText];
        self.bodyLabel.text = bodyTeaserText;
        self.bodyLabel.font = [UIFont systemFontOfSize:TEASER_SIZE];
        self.bodyLabel.numberOfLines = 0;
        self.bodyLabel.lineBreakMode = UILineBreakModeWordWrap;
                
        // Download image
        [self.imageView setImageWithURL:self.newsfeed.imageURL
                       placeholderImage:nil
                                success:^(UIImage *image) {
                                    [weakSelf setNeedsLayout];
                                    [weakSelf setNeedsDisplay];
                                } failure:^(NSError *error) {
             
                                }];
        
        // Make view hierarchy
        [self.containerView addSubview:self.titleLabel];
        [self.containerView addSubview:self.bodyLabel];
        [self.contentView addSubview:self.containerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = [self.containerView bounds];
    
    if (! self.editing) {
        
        CGFloat maxTitleWidth;
        CGFloat titleLeftMargin;
        
        // Layout if we have an image
        if ( ![self.newsfeed.imageURL.absoluteString isEqualToString:@""] ) { 
            [self.imageView setFrame:CGRectMake(CELL_PADDING,
                                                CELL_PADDING, 
                                                IMAGE_SIZE, 
                                                IMAGE_SIZE)];
            maxTitleWidth = contentRect.size.width - 2*CELL_PADDING - IMAGE_SIZE - CELL_ELEMENT_PADDING;
            titleLeftMargin = CELL_PADDING + IMAGE_SIZE + CELL_ELEMENT_PADDING;
        }
        // Layout if there is no image
        else {
            maxTitleWidth = contentRect.size.width - 2*CELL_PADDING;
            titleLeftMargin = CELL_PADDING;
        }
        
        // Layout for title
        CGSize titleSize = [self.newsfeed.title sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]
                                                                        constrainedToSize:CGSizeMake(maxTitleWidth, 
                                                                                                     400) 
                                                                            lineBreakMode:UILineBreakModeWordWrap];
        [self.titleLabel setFrame:CGRectMake(titleLeftMargin, 
                                             CELL_PADDING, 
                                             maxTitleWidth, 
                                             titleSize.height)];
        
        // Layout for body teaser
        CGSize bodySize = [self.bodyLabel.text sizeWithFont:[UIFont systemFontOfSize:TEASER_SIZE]
                                          constrainedToSize:CGSizeMake(contentRect.size.width - 2*CELL_PADDING, 
                                                                       400) 
                                              lineBreakMode:UILineBreakModeWordWrap];
        [self.bodyLabel setFrame:CGRectMake(CELL_PADDING, 
                                            CELL_PADDING 
                                            + MAX(self.imageView.frame.size.height,
                                                  self.titleLabel.frame.size.height)
                                            + CELL_ELEMENT_PADDING, 
                                            contentRect.size.width - 2*CELL_PADDING, 
                                            bodySize.height)];
                                                              
    }
    
    [self.containerView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    _height = 2*CELL_PADDING + 2* CELL_ELEMENT_PADDING + MAX(self.imageView.frame.size.height,
                                                             self.titleLabel.frame.size.height) + self.bodyLabel.frame.size.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
