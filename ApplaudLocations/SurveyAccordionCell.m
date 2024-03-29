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
#import "SurveyDisplayConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation SurveyAccordionCell

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
              field:(SurveyField *)field {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.field = field;
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        
        // Initialize UI elements, starting with the question label...
        self.questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.questionLabel.text = field.label;
        self.questionLabel.numberOfLines = 0;
        self.questionLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.questionLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        
        if( self.field.type == RADIO ){
            self.field.type = TEXTAREA;
        }
        
        // ...and then the question widgets
        self.questionWidgets = [[NSMutableArray alloc] init];
        switch ( [field type] ) {
            case TEXTAREA:
            {
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
                textView.layer.cornerRadius = 5;
                textView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
                textView.layer.borderWidth = 2.0;
                [textView setReturnKeyType:UIReturnKeyDone];
                textView.delegate = self;
                textView.font = [UIFont systemFontOfSize:16.0];
                [self.questionWidgets addObject:textView];
            }
                break;
            case RADIO:
                [self.questionWidgets addObject:[[UISegmentedControl alloc] initWithItems:[field options]]];
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
                    
                    [self.questionWidgets addObject:optionLabel];
                    [self.questionWidgets addObject:yesNo];
                    
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
                [self.questionWidgets addObject:textField];
            }
                break;
        }
        
        // Start off question body as hidden
        isExpanded = NO;
        [self hideWidgets];
        
        // Add all cell content
        [self.containerView addSubview:self.questionLabel];
        for ( UIView *widget in self.questionWidgets ) {
            [self.containerView addSubview:widget];
        }
        [self.contentView addSubview:self.containerView];
        
        [self layoutSubviews];
        self.containerView.frame = self.contentView.frame;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = [self.containerView bounds];
    
    // We will never edit, but it's clean.
    if (! self.editing) {
        CGSize questionLabelSize = [self.questionLabel.text
                                    sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]
                                    constrainedToSize:CGSizeMake(contentRect.size.width - 2*CELL_PADDING,400)
                                    lineBreakMode:UILineBreakModeWordWrap];
        
        // Question label
        self.questionLabel.frame = CGRectMake(CELL_PADDING,
                                              CELL_PADDING,
                                              contentRect.size.width - 2*CELL_PADDING,
                                              questionLabelSize.height);
        
        // The baseline height of an expanded cell. This will be adjusted in each case of the following switch statement.
        _expandedHeight = questionLabelSize.height + 2*CELL_ELEMENT_PADDING + 2*CELL_PADDING;
        
        // Question widget
        switch ( self.field.type ) {
            case TEXTAREA:
            {
                UIView *textArea = [self.questionWidgets objectAtIndex:0];
                [textArea setFrame:CGRectMake(CELL_PADDING, 
                                              self.questionLabel.frame.origin.y + self.questionLabel.frame
                                              .size.height + 2*CELL_ELEMENT_PADDING, 
                                              contentRect.size.width - 2*CELL_PADDING, 
                                              2*WIDGET_HEIGHT)];
                _expandedHeight += textArea.frame.size.height;
            }
                break;
            case TEXTFIELD:
            {
                UIView *textField = [self.questionWidgets objectAtIndex:0];
                [textField setFrame:CGRectMake(CELL_PADDING,
                                               self.questionLabel.frame.origin.y + self.questionLabel.frame
                                               .size.height + 2*CELL_ELEMENT_PADDING, 
                                               contentRect.size.width - 2*CELL_PADDING, 
                                               WIDGET_HEIGHT)];
                _expandedHeight += textField.frame.size.height;
            }
                break;
            case RADIO:
            {
                UIView *radioGroup = [self.questionWidgets objectAtIndex:0];
                [radioGroup setFrame:CGRectMake(CELL_PADDING, 
                                                self.questionLabel.frame.origin.y + self.questionLabel.frame
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
                for ( UIView *widget in self.questionWidgets ) {
                    if ( [widget isKindOfClass:[UILabel class]] ) {
                        [widget setFrame:CGRectMake(CELL_PADDING, 
                                                    (widget.tag-1)*(CELL_ELEMENT_PADDING + WIDGET_HEIGHT)
                                                    + self.questionLabel.frame.origin.y + self.questionLabel.frame.size.height + 2*CELL_ELEMENT_PADDING,
                                                    (contentRect.size.width - 2*CELL_PADDING)/2, 
                                                    WIDGET_HEIGHT)];
                    }
                    else if ( [widget isKindOfClass:[UISegmentedControl class]] ) {
                        [widget setFrame:CGRectMake((contentRect.size.width - 2*CELL_PADDING)/2
                                                    + CELL_ELEMENT_PADDING, 
                                                    ((-widget.tag)-1)*(CELL_ELEMENT_PADDING + WIDGET_HEIGHT)
                                                    + self.questionLabel.frame.origin.y + self.questionLabel.frame.size.height + 2*CELL_ELEMENT_PADDING,
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
        
        if ( ! isExpanded ) {
            self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                                self.contentView.frame.origin.y,
                                                self.contentView.frame.size.width,
                                                questionLabelSize.height + 2*CELL_PADDING);
        } else {
            self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                                self.contentView.frame.origin.y,
                                                self.contentView.frame.size.width,
                                                _expandedHeight);
        }
    }
}

- (void)expand {
    if ( isExpanded )
        return;
    
    for ( UIView *widget in self.questionWidgets ) {
        [widget setHidden:NO];
    }

    isExpanded = YES;
}

- (void)hideWidgets {
    for ( UIView *widget in self.questionWidgets ) {
        [widget setHidden:YES];
    }
    [timer invalidate];
}

- (void)contract {
    if (! isExpanded )
        return;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:ACCORDION_TIME
                                             target:self
                                           selector:@selector(hideWidgets)
                                           userInfo:nil
                                            repeats:NO];
    for ( UIView *widget in self.questionWidgets ) {
        [widget resignFirstResponder];
    }
    isExpanded = NO;
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
            UITextView *textView = (UITextView*)self.questionWidgets[0];
            if ( [textView hasText] )
                return @[textView.text];
        }
        case TEXTFIELD:
        {
            UITextField *textField = (UITextField*)self.questionWidgets[0];
            if ( [textField hasText] )
                return @[textField.text];
        }
            break;
        case RADIO:
        {
            UISegmentedControl *radioGroup = (UISegmentedControl*)self.questionWidgets[0];
            if(radioGroup.selectedSegmentIndex != UISegmentedControlNoSegment) {
                return @[[radioGroup titleForSegmentAtIndex:radioGroup.selectedSegmentIndex]];
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
    [(UITextView*)self.questionWidgets[0] resignFirstResponder];
    return NO;
}

/*
 * resign keyboard on 'return'
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ( [text isEqualToString:@"\n"] ) {
        [(UITextView*)self.questionWidgets[0] resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
