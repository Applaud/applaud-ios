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

@interface SurveyAccordionCell : UITableViewCell <UITextFieldDelegate, UITextViewDelegate> {
    BOOL isExpanded;
    NSTimer *timer;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier field:(SurveyField *)field;
- (void)expand;
- (void)contract;
- (NSArray *)getAnswer;

@property (strong, nonatomic) UIView *containerView;    // Contains all the widgets
@property (strong, nonatomic) UILabel *questionLabel;   // The question's text
@property (strong, nonatomic) NSMutableArray *questionWidgets;  // Widgets with which the user interacts
@property (readonly) CGFloat expandedHeight;            // How tall this cell should be drawn when expanded
@property (strong, nonatomic) SurveyField *field;	// Field that this cell represents

@end
