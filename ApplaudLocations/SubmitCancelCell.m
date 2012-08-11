//
//  SubmitCancelCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "SubmitCancelCell.h"

#define CELL_PADDING 10.0f

@implementation SubmitCancelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.submitCancel = [[UISegmentedControl alloc] initWithItems:
                             [NSArray arrayWithObjects:@"Submit", @"Cancel", nil]];
        [self.submitCancel addTarget:self
                              action:@selector(segmentSelected:)
                    forControlEvents:UIControlEventValueChanged];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.submitCancel];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.submitCancel setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.submitCancel.frame = CGRectMake(0, 0,
                                         self.contentView.frame.size.width,
                                         self.contentView.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)segmentSelected:(id)sender {
    int which = self.submitCancel.selectedSegmentIndex;
    // "Submit"
    if ( 0 == which ) {
        [self.delegate submitButtonPressed];
    }
    // "Cancel"
    else if ( 1 == which ) {
        [self.delegate cancelButtonPressed];
    }
}

@end
