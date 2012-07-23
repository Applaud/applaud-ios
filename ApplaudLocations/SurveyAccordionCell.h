//
//  SurveyAccordionCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/20/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//
//  SurveyAccordionCell : A UITableViewCell that expands when selected, revealing additional content.
//

#import <UIKit/UIKit.h>
#import "SurveyField.h"

#define CELL_ELEMENT_PADDING 5.0f   // how much space between things inside of the cell
#define CELL_PADDING 10.0f          // space between cell wall and anything else
#define CELL_MARGIN 22.0f           // space between outside of the cell and edge of the screen
#define TITLE_SIZE 18.0f            // size of newsfeed item titles
#define SUBTITLE_SIZE 12.0f         // size of newsfeed item subtitles
#define WIDGET_HEIGHT 30.0f         // standard height of a widget (like an option)

#define POSITIVE_RESPONSE 0         // What index a UISegmentedControl is in that indicates a "yes"
                                    // response under a checkbox group

@interface SurveyAccordionCell : UITableViewCell <UITextFieldDelegate, UITextViewDelegate>

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier field:(SurveyField *)field;
- (void)expand;
- (void)contract;
- (NSArray *)getAnswer;

@property (strong, nonatomic) UIView *containerView;    // Contains all the widgets
@property (strong, nonatomic) UILabel *questionLabel;   // The question's text
@property (strong, nonatomic) NSMutableArray *questionWidgets;  // Widgets with which the user interacts
@property (readonly) CGFloat expandedHeight;            // How tall this cell should be drawn when expanded
@property (readonly) CGFloat contractedHeight;		// How tall this cell should be drawn when contracted
@property (strong, nonatomic) SurveyField *field;	// Field that this cell represents

@end
