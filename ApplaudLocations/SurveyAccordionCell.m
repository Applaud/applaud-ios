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
#import <QuartzCore/QuartzCore.h>

@implementation SurveyAccordionCell

@synthesize questionLabel, questionWidget, hrView;
@synthesize adjustedHeight = _adjustedHeight;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
              field:(SurveyField *)field {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        myField = field;
        
        // Initialize UI elements, starting with the question label...
        questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        questionLabel.text = field.label;
        questionLabel.numberOfLines = 0;
        questionLabel.lineBreakMode = UILineBreakModeWordWrap;
        questionLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        hrView = [[UIView alloc] initWithFrame:CGRectZero];
        
        // ...and then the horizontal rule
        hrView.backgroundColor = [UIColor grayColor];
        
        // ...and then the question widget
        switch ( [field type] ) {
            case TEXTAREA:
                questionWidget = [[UITextView alloc] initWithFrame:CGRectZero];
                questionWidget.layer.cornerRadius = 5;
                questionWidget.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
                questionWidget.layer.borderWidth = 2.0;
                break;
            case RADIO:
                questionWidget = [[UISegmentedControl alloc] initWithItems:[field options]];
                break;
            case CHECKBOX:
                questionWidget = [[UIView alloc] initWithFrame:CGRectZero];
                
                // Create the options
                for ( NSString *option in [field options] ) {
                    UIView *optionView = [[UIView alloc] initWithFrame:CGRectZero];
                    
                    UILabel *optionLabel = [[UILabel alloc] init];
                    [optionLabel setTag:100];
                    optionLabel.text = option;
                    
                    UISegmentedControl *yesNo = [[UISegmentedControl alloc] initWithItems:
                                                 [NSArray arrayWithObjects:@"yes", @"no", nil]];
                    [yesNo setTag:101];
                    
                    [optionView addSubview:optionLabel];
                    [optionView addSubview:yesNo];
                    
                    [questionWidget addSubview:optionView];
                }
                break;
            case TEXTFIELD:
                questionWidget = [[UITextField alloc] initWithFrame:CGRectZero];
                questionWidget.layer.cornerRadius = 5;
                questionWidget.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
                questionWidget.layer.borderWidth = 2.0;
                break;
        }
        
        // Start off question body as hidden
        [self contract];
        
        // Add all cell content
        [self.contentView addSubview:questionLabel];
        [self.contentView addSubview:hrView];
        [self.contentView addSubview:questionWidget];
        
        // Draw visual effects
        // Set our color and shape
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView.layer setCornerRadius:7.0f];
        [self.contentView.layer setMasksToBounds:YES];
        [self.contentView.layer setBorderWidth:1.0f];
        [self.contentView.layer setBorderColor:[[UIColor grayColor] CGColor]];
        // Some nice visual FX
        [self.contentView.layer setShadowRadius:5.0f];
        [self.contentView.layer setShadowOpacity:0.2f];
        [self.contentView.layer setShadowOffset:CGSizeMake(1, 0)];
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
        
        // Question label
        self.questionLabel.frame = CGRectMake(contentRect.origin.x + CELL_PADDING,
                                              contentRect.origin.y + CELL_PADDING,
                                              contentRect.size.width - 2*CELL_PADDING,
                                              questionLabelSize.height);
        
        // Horizontal rule
        self.hrView.frame = CGRectMake(contentRect.origin.x + CELL_PADDING,
                                       contentRect.origin.y + CELL_PADDING + questionLabelSize.height + CELL_ELEMENT_PADDING,
                                       contentRect.size.width - 2*CELL_PADDING,
                                       1);
        
        // Question widget
        switch ( myField.type ) {
            case TEXTAREA:
                [questionWidget setFrame:CGRectMake(CELL_PADDING, 
                                                    hrView.frame.origin.y + hrView.frame
                                                    .size.height + CELL_ELEMENT_PADDING, 
                                                    contentRect.size.width - 2*CELL_PADDING, 
                                                    2*WIDGET_HEIGHT)];
                break;
            case TEXTFIELD:
                [questionWidget setFrame:CGRectMake(CELL_PADDING, 
                                                    hrView.frame.origin.y + hrView.frame
                                                    .size.height + CELL_ELEMENT_PADDING, 
                                                    contentRect.size.width - 2*CELL_PADDING, 
                                                    WIDGET_HEIGHT)];
                break;
            case RADIO:
                [questionWidget setFrame:CGRectMake(CELL_PADDING, 
                                                    hrView.frame.origin.y + hrView.frame
                                                    .size.height + CELL_ELEMENT_PADDING, 
                                                    contentRect.size.width - 2*CELL_PADDING, 
                                                    WIDGET_HEIGHT)];
                break;
            case CHECKBOX:
                // layout for the option views.
                for ( int i=0; i<questionWidget.subviews.count; i++ ) {
                    UIView *optionView = [questionWidget.subviews objectAtIndex:i];
                    
                    UIView *optionLabel = [optionView viewWithTag:100];
                    UIView *widgetView = [optionView viewWithTag:101];
                    
                    [optionLabel setFrame:CGRectMake(0, 
                                                     i*(CELL_ELEMENT_PADDING + WIDGET_HEIGHT), 
                                                     (contentRect.size.width - 2*CELL_PADDING)/2, 
                                                     WIDGET_HEIGHT)];
                    [widgetView setFrame:CGRectMake((contentRect.size.width - 2*CELL_PADDING)/2
                                                    + CELL_ELEMENT_PADDING, 
                                                    i*(CELL_ELEMENT_PADDING + WIDGET_HEIGHT), 
                                                    (contentRect.size.width - 2*CELL_PADDING)/2 
                                                    - CELL_ELEMENT_PADDING, 
                                                    WIDGET_HEIGHT)];
                    [optionView setFrame:CGRectMake(0, 
                                                    0, 
                                                    contentRect.size.width - 2*CELL_PADDING, 
                                                    WIDGET_HEIGHT)];
                }
                
                [questionWidget setFrame:CGRectMake(CELL_PADDING, 
                                                    hrView.frame.origin.y 
                                                    + hrView.frame.size.height 
                                                    + CELL_ELEMENT_PADDING, 
                                                    contentRect.size.width - 2*CELL_PADDING, 
                                                    questionWidget.subviews.count * WIDGET_HEIGHT
                                                    + (questionWidget.subviews.count-1) * CELL_ELEMENT_PADDING)];
                break;
        }
        
        _adjustedHeight = questionLabelSize.height + hrView.frame.size.height + questionWidget.frame.size.height + 2*CELL_ELEMENT_PADDING + 2*CELL_PADDING;
    }
}

- (void)expand {
    [self.hrView setHidden:NO];
    [self.questionWidget setHidden:NO];
}

- (void)contract {
    [self.hrView setHidden:YES];
    [self.questionWidget setHidden:YES];
    [self.questionWidget resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
