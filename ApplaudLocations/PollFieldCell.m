//
//  PollOptionCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PollFieldCell.h"

#define CELL_PADDING 10.0f

@implementation PollFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialize the textfield
        self.textField = [[UITextField alloc] init];
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textField.placeholder = placeholder;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.textField.frame = CGRectMake(CELL_PADDING,
                                      CELL_PADDING,
                                      self.contentView.frame.size.width - 2*CELL_PADDING,
                                      self.contentView.frame.size.height - 2*CELL_PADDING);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	// The user can only edit the text field when in editing mode.
    [super setEditing:editing animated:animated];
	self.textField.enabled = editing;
}

@end
