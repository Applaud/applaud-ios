//
//  WhisperCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/10/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "WhisperCell.h"

#define CELL_PADDING 10.0f

@implementation WhisperCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialize the textView
        self.textView = [[UIPlaceHolderTextView alloc] init];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:self.textView];
    }
    return self;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textView.placeholder = _placeholder;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textView.frame = CGRectMake(0, CELL_PADDING,
                                     self.contentView.frame.size.width,
                                     self.contentView.frame.size.height - 2*CELL_PADDING);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
