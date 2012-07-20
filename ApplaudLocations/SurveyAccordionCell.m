//
//  SurveyAccordionCell.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/20/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//
//  SurveyAccordionCell : A UITableViewCell that expands when selected, revealing additional content.
//

#import "SurveyAccordionCell.h"

@implementation SurveyAccordionCell

@synthesize questionLabel, questionWidget, hrView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier field:(SurveyField *)field {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        questionLabel.text = field.label;
        questionLabel.numberOfLines = 0;
        questionLabel.lineBreakMode = UILineBreakModeWordWrap;
        questionLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        hrView = [[UIView alloc] initWithFrame:CGRectZero];
        hrView.backgroundColor = [UIColor grayColor];
        [hrView setHidden:YES];
        
        [self.contentView addSubview:questionLabel];
        [self.contentView addSubview:hrView];
        
        //TODO: construct widget.
        questionWidget = nil;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = [self.contentView bounds];
    
    // We will never edit, but it's clean.
    if (! self.editing) {
        CGSize questionLabelSize = [questionLabel.text
                                    sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]
                                    constrainedToSize:CGSizeMake(contentRect.size.width - 2*CELL_PADDING,400)
                                    lineBreakMode:UILineBreakModeWordWrap];
        self.questionLabel.frame = CGRectMake(contentRect.origin.x + CELL_PADDING,
                                              contentRect.origin.y + CELL_PADDING,
                                              contentRect.size.width - 2*CELL_PADDING,
                                              questionLabelSize.height);
        
        self.hrView.frame = CGRectMake(contentRect.origin.x + CELL_PADDING,
                                       contentRect.origin.y + CELL_PADDING + questionLabelSize.height + CELL_ELEMENT_PADDING,
                                       contentRect.size.width - 2*CELL_PADDING,
                                       1);
    }
}

- (void)expand {
    [self.hrView setHidden:NO];
}

- (void)contract {
    [self.hrView setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
//    if ( selected )
//        [self expand];
//    else
//        [self contract];
}

@end
