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

#define CELL_ELEMENT_PADDING 5.0f   // how much space between things inside of the cell
#define CELL_PADDING 10.0f          // space between cell wall and anything else
#define CELL_MARGIN 22.0f           // space between outside of the cell and edge of the screen
#define TITLE_SIZE 18.0f            // size of newsfeed item titles
#define SUBTITLE_SIZE 12.0f         // size of newsfeed item subtitles

@interface SurveyAccordionCell : UITableViewCell {
    UIView *containerView;  // Wrapper around stuff inside of the cell. Goes inside contentView.
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier label:(NSString *)label type:(NSString *)widgetType;
- (void)expand;
- (void)contract;

@property (strong, nonatomic) UILabel *questionLabel;   // The question's text
@property (strong, nonatomic) UIView *hrView;           // A horizontal rule between the above and ...
@property (strong, nonatomic) UIView *questionWidget;   // the widget with which the user interacts.

@end
