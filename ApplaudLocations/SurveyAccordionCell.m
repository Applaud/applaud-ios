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

@synthesize questionLabel, questionWidgets, hrView;
@synthesize adjustedHeight = _adjustedHeight;
@synthesize containerView = _containerView;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
              field:(SurveyField *)field {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        myField = field;
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        
        // Initialize UI elements, starting with the question label...
        questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        questionLabel.text = field.label;
        questionLabel.numberOfLines = 0;
        questionLabel.lineBreakMode = UILineBreakModeWordWrap;
        questionLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        hrView = [[UIView alloc] initWithFrame:CGRectZero];
        
        // ...and then the horizontal rule
        hrView.backgroundColor = [UIColor grayColor];
        
        // ...and then the question widgets
        questionWidgets = [[NSMutableArray alloc] init];
        switch ( [field type] ) {
            case TEXTAREA:
            {
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
                textView.layer.cornerRadius = 5;
                textView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
                textView.layer.borderWidth = 2.0;
                [questionWidgets addObject:textView];
            }
                break;
            case RADIO:
                [questionWidgets addObject:[[UISegmentedControl alloc] initWithItems:[field options]]];
                break;
            case CHECKBOX:
            {
                // Create the options
                int i=0;
                for ( NSString *option in [field options] ) {
                    UILabel *optionLabel = [[UILabel alloc] init];
                    optionLabel.text = option;
                    optionLabel.tag = i;
                    
                    UISegmentedControl *yesNo = [[UISegmentedControl alloc] initWithItems:
                                                 [NSArray arrayWithObjects:@"yes", @"no", nil]];
                    yesNo.tag = i;
                    
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
                [questionWidgets addObject:textField];
            }
                break;
        }
        
        // Start off question body as hidden
        [self contract];
        
        // Add all cell content
        [self.containerView addSubview:questionLabel];
        [self.containerView addSubview:hrView];
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
        
        // Not expanded when we load
        isExpanded = NO;
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
        
	// The baseline height of an expanded cell. This will be adjusted in each case of the following switch statement.
        _adjustedHeight = questionLabelSize.height + hrView.frame.size.height + 2*CELL_ELEMENT_PADDING + 2*CELL_PADDING;

        // Question widget
        switch ( myField.type ) {
            case TEXTAREA:
            {
                UIView *textArea = [questionWidgets objectAtIndex:0];
                [textArea setFrame:CGRectMake(CELL_PADDING, 
                                              hrView.frame.origin.y + hrView.frame
                                              .size.height + CELL_ELEMENT_PADDING, 
                                              contentRect.size.width - 2*CELL_PADDING, 
                                              2*WIDGET_HEIGHT)];
		_adjustedHeight += textArea.frame.size.height;
            }
                break;
            case TEXTFIELD:
            {
                UIView *textField = [questionWidgets objectAtIndex:0];
                [textField setFrame:CGRectMake(CELL_PADDING, 
                                               hrView.frame.origin.y + hrView.frame
                                               .size.height + CELL_ELEMENT_PADDING, 
                                               contentRect.size.width - 2*CELL_PADDING, 
                                               WIDGET_HEIGHT)];
		_adjustedHeight += textField.frame.size.height;
            }
                break;
            case RADIO:
            {
                UIView *radioGroup = [questionWidgets objectAtIndex:0];
                [radioGroup setFrame:CGRectMake(CELL_PADDING, 
                                                hrView.frame.origin.y + hrView.frame
                                                .size.height + CELL_ELEMENT_PADDING, 
                                                contentRect.size.width - 2*CELL_PADDING, 
                                                WIDGET_HEIGHT)];
		_adjustedHeight += radioGroup.frame.size.height;
            }
                break;
            case CHECKBOX:
	    {
		int boxCount = 0;
                // layout for the option views.
                for ( UIView *widget in questionWidgets ) {
                    if ( [widget isKindOfClass:[UILabel class]] ) {
                        [widget setFrame:CGRectMake(CELL_PADDING, 
                                                    widget.tag*(CELL_ELEMENT_PADDING + WIDGET_HEIGHT)
                                                    + hrView.frame.origin.y + hrView.frame.size.height + CELL_ELEMENT_PADDING,
                                                    (contentRect.size.width - 2*CELL_PADDING)/2, 
                                                    WIDGET_HEIGHT)];
                    }
                    else if ( [widget isKindOfClass:[UISegmentedControl class]] ) {
                        [widget setFrame:CGRectMake((contentRect.size.width - 2*CELL_PADDING)/2
                                                    + CELL_ELEMENT_PADDING, 
                                                    widget.tag*(CELL_ELEMENT_PADDING + WIDGET_HEIGHT)
                                                    + hrView.frame.origin.y + hrView.frame.size.height + CELL_ELEMENT_PADDING,
                                                    (contentRect.size.width - 2*CELL_PADDING)/2 
                                                    - CELL_ELEMENT_PADDING, 
                                                    WIDGET_HEIGHT)];
			boxCount++;
                    }
                }

		_adjustedHeight += (boxCount-1) * (WIDGET_HEIGHT + CELL_ELEMENT_PADDING) + WIDGET_HEIGHT;
	    }
                break;
        }

    }
    //    NSLog(@"Container view: %@",self.containerView);
    //    NSLog(@"Content view: %@",self.contentView);
    //    NSLog(@"questionWidget: %@",self.questionWidget);
    
    [self.containerView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
}

/** touch events override **/
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    if ( isExpanded && CGRectContainsPoint(self.questionWidget.frame, [touch locationInView:self]) ) {
//        [self.questionWidget touchesBegan:touches withEvent:event];
//    } else {
//        [super touchesBegan:touches withEvent:event];        
//    }
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    if ( isExpanded && CGRectContainsPoint(self.questionWidget.frame, [touch locationInView:self]) ) {
//        [self.questionWidget touchesCancelled:touches withEvent:event];
//    } else {
//        [super touchesCancelled:touches withEvent:event];
//    }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    if ( isExpanded && CGRectContainsPoint(self.questionWidget.frame, [touch locationInView:self]) ) {
//        [self.questionWidget touchesEnded:touches withEvent:event];
//    } else {
//        [super touchesEnded:touches withEvent:event];
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    if ( isExpanded && CGRectContainsPoint(self.questionWidget.frame, [touch locationInView:self]) ) {
//        [self.questionWidget touchesMoved:touches withEvent:event];
//    } else {
//        [super touchesMoved:touches withEvent:event];
//    }
//}
/** end of touch overrides **/


- (void)expand {
    [self.hrView setHidden:NO];
    for ( UIView *widget in questionWidgets )
        [widget setHidden:NO];
    
    isExpanded = YES;
}

- (void)contract {
    [self.hrView setHidden:YES];
    for ( UIView *widget in questionWidgets ) {
        [widget setHidden:YES];
        [widget resignFirstResponder];
    }
}

@end
