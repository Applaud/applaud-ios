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

@synthesize questionLabel, questionWidgets;
@synthesize expandedHeight = _expandedHeight, contractedHeight = _contractedHeight;
@synthesize containerView = _containerView;
@synthesize field = _field;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
              field:(SurveyField *)field {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.field = field;
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        
        // Initialize UI elements, starting with the question label...
        questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        questionLabel.text = field.label;
        questionLabel.numberOfLines = 0;
        questionLabel.lineBreakMode = UILineBreakModeWordWrap;
        questionLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        
        // ...and then the question widgets
        questionWidgets = [[NSMutableArray alloc] init];
        switch ( [field type] ) {
            case TEXTAREA:
            {
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
                textView.layer.cornerRadius = 5;
                textView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
                textView.layer.borderWidth = 2.0;
                [textView setReturnKeyType:UIReturnKeyDone];
                textView.delegate = self;
                [questionWidgets addObject:textView];
            }
                break;
            case RADIO:
                [questionWidgets addObject:[[UISegmentedControl alloc] initWithItems:[field options]]];
                break;
            case CHECKBOX:
            {
                // Create the options. Options have sequential tags, starting at 1.
                // UISegmentedControl tags grow in the negative direction, UILabels in the
                // positive direction.
                int i=1;
                for ( NSString *option in [field options] ) {
                    UILabel *optionLabel = [[UILabel alloc] init];
                    optionLabel.text = option;
                    optionLabel.tag = i;
                    
                    UISegmentedControl *yesNo = [[UISegmentedControl alloc] initWithItems:
                                                 [NSArray arrayWithObjects:@"yes", @"no", nil]];
                    yesNo.tag = -i;
                    
                    [questionWidgets addObject:optionLabel];
                    [questionWidgets addObject:yesNo];
                    
                    i++;
                }
            }
                break;
            case TEXTFIELD:
            {
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
                textField.layer.cornerRadius = 5;
                textField.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
                textField.layer.borderWidth = 2.0;
                [textField setReturnKeyType:UIReturnKeyDone];
                textField.delegate = self;
                [questionWidgets addObject:textField];
            }
                break;
        }
        
        // Start off question body as hidden
        [self contract];
        
        // Add all cell content
        [self.containerView addSubview:questionLabel];
        for ( UIView *widget in questionWidgets ) {
            [self.containerView addSubview:widget];
        }
        [self.contentView addSubview:self.containerView];
        
        // Draw visual effects
        // Set our shape
        [self.contentView.layer setCornerRadius:7.0f];
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
    
    CGRect contentRect = [self.containerView bounds];
    
    // We will never edit, but it's clean.
    if (! self.editing) {
        CGSize questionLabelSize = [questionLabel.text
                                    sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]
                                    constrainedToSize:CGSizeMake(contentRect.size.width - 2*CELL_PADDING,400)
                                    lineBreakMode:UILineBreakModeWordWrap];
        
        // Set the contracted height based off of just the question label
        _contractedHeight = questionLabelSize.height + 2*CELL_PADDING + 2*CELL_ELEMENT_PADDING;
        
        // Question label
        self.questionLabel.frame = CGRectMake(contentRect.origin.x + CELL_PADDING,
                                              contentRect.origin.y + CELL_PADDING,
                                              contentRect.size.width - 2*CELL_PADDING,
                                              questionLabelSize.height);
        
        // The baseline height of an expanded cell. This will be adjusted in each case of the following switch statement.
        _expandedHeight = questionLabelSize.height + 2*CELL_ELEMENT_PADDING + 2*CELL_PADDING;
        
        // Question widget
        switch ( self.field.type ) {
            case TEXTAREA:
            {
                UIView *textArea = [questionWidgets objectAtIndex:0];
                [textArea setFrame:CGRectMake(CELL_PADDING, 
                                              questionLabel.frame.origin.y + questionLabel.frame
                                              .size.height + 2*CELL_ELEMENT_PADDING, 
                                              contentRect.size.width - 2*CELL_PADDING, 
                                              2*WIDGET_HEIGHT)];
                _expandedHeight += textArea.frame.size.height;
            }
                break;
            case TEXTFIELD:
            {
                UIView *textField = [questionWidgets objectAtIndex:0];
                [textField setFrame:CGRectMake(CELL_PADDING, 
                                               questionLabel.frame.origin.y + questionLabel.frame
                                               .size.height + 2*CELL_ELEMENT_PADDING, 
                                               contentRect.size.width - 2*CELL_PADDING, 
                                               WIDGET_HEIGHT)];
                _expandedHeight += textField.frame.size.height;
            }
                break;
            case RADIO:
            {
                UIView *radioGroup = [questionWidgets objectAtIndex:0];
                [radioGroup setFrame:CGRectMake(CELL_PADDING, 
                                                questionLabel.frame.origin.y + questionLabel.frame
                                                .size.height + 2*CELL_ELEMENT_PADDING, 
                                                contentRect.size.width - 2*CELL_PADDING, 
                                                WIDGET_HEIGHT)];
                _expandedHeight += radioGroup.frame.size.height;
            }
                break;
            case CHECKBOX:
            {
                int boxCount = 0;
                // layout for the option views.
                for ( UIView *widget in questionWidgets ) {
                    if ( [widget isKindOfClass:[UILabel class]] ) {
                        [widget setFrame:CGRectMake(CELL_PADDING, 
                                                    (widget.tag-1)*(CELL_ELEMENT_PADDING + WIDGET_HEIGHT)
                                                    + questionLabel.frame.origin.y + questionLabel.frame.size.height + 2*CELL_ELEMENT_PADDING,
                                                    (contentRect.size.width - 2*CELL_PADDING)/2, 
                                                    WIDGET_HEIGHT)];
                    }
                    else if ( [widget isKindOfClass:[UISegmentedControl class]] ) {
                        [widget setFrame:CGRectMake((contentRect.size.width - 2*CELL_PADDING)/2
                                                    + CELL_ELEMENT_PADDING, 
                                                    ((-widget.tag)-1)*(CELL_ELEMENT_PADDING + WIDGET_HEIGHT)
                                                    + questionLabel.frame.origin.y + questionLabel.frame.size.height + 2*CELL_ELEMENT_PADDING,
                                                    (contentRect.size.width - 2*CELL_PADDING)/2 
                                                    - CELL_ELEMENT_PADDING, 
                                                    WIDGET_HEIGHT)];
                        boxCount++;
                    }
                }
                
                _expandedHeight += (boxCount-1) * (WIDGET_HEIGHT + CELL_ELEMENT_PADDING) + WIDGET_HEIGHT;
            }
                break;
        }
        
    }
    
    [self.containerView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
}

- (void)expand {
    for ( UIView *widget in questionWidgets ) {
        [widget setHidden:NO];
    }
}

- (void)contract {
    for ( UIView *widget in questionWidgets ) {
        [widget setHidden:YES];
        [widget resignFirstResponder];
    }
}

/*
 * Gets the user's answers, based on the type of widget that this question uses.
 * This returns an NSArray because the server is expecting that in JSON, plus
 * the checkboxes may have multiple answers.
 */
- (NSArray *)getAnswer {
    switch(self.field.type) {
        case TEXTAREA:
        {
            UITextView *textView = (UITextView*)[self.questionWidgets objectAtIndex:0];
            if ( [textView hasText] )
                return [NSArray arrayWithObject:textView.text];
        }
        case TEXTFIELD:
        {
            UITextField *textField = (UITextField*)[self.questionWidgets objectAtIndex:0];
            if ( [textField hasText] )
                return [NSArray arrayWithObject:textField.text];
        }
            break;
        case RADIO:
        {
            UISegmentedControl *radioGroup = (UISegmentedControl*)[self.questionWidgets objectAtIndex:0];
            if(radioGroup.selectedSegmentIndex != UISegmentedControlNoSegment) {
                return [NSArray arrayWithObject:[radioGroup titleForSegmentAtIndex:radioGroup.selectedSegmentIndex]];
            }
        }
            break;
        case CHECKBOX:
        {
            NSMutableArray *answers = [[NSMutableArray alloc] init];
            for ( UIView *widget in self.questionWidgets ) {
                if ( [widget isKindOfClass:[UISegmentedControl class]] ) {
                    UISegmentedControl *widgetControl = (UISegmentedControl*)widget;
                    if ( POSITIVE_RESPONSE == [widgetControl selectedSegmentIndex] ) {
                        UILabel *response = (UILabel*)[self.containerView viewWithTag:-widgetControl.tag]; 
                        [answers addObject:response.text];
                    }
                }
            }
            if ( answers.count )
                return answers;
        }
            break;
    }
    return [[NSArray alloc] init ]; // If we don't have an answer.
}

#pragma mark -
#pragma mark Delegate Methods from UITextView/Field

/*
 * resign keyboard on 'return'
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [(UITextView*)[self.questionWidgets objectAtIndex:0] resignFirstResponder];
    return NO;
}

/*
 * resign keyboard on 'return'
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ( [text isEqualToString:@"\n"] ) {
        [(UITextView*)[self.questionWidgets objectAtIndex:0] resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
