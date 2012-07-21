//
//  QuestionsViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Survey.h"
#import "SurveyFieldViewController.h"
#import "ConnectionManager.h"
#import "AppDelegate.h"
#import "Business.h"

#define CELL_ELEMENT_PADDING 5.0f   // how much space between things inside of the cell
#define CELL_PADDING 10.0f          // space between cell wall and anything else
#define CELL_MARGIN 22.0f           // space between outside of the cell and edge of the screen
#define TITLE_SIZE 18.0f            // size of newsfeed item titles
#define SUBTITLE_SIZE 12.0f         // size of newsfeed item subtitles

@interface QuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    // Tracks what questions have been selected. 
    NSMutableArray *questionSelections;
}

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) Survey *survey;
@property (nonatomic, strong) NSMutableArray *surveyControllers;
@property (weak, nonatomic) IBOutlet UITextView *summaryText;
@property (weak, nonatomic) IBOutlet UITableView *questionsTable;
@property (strong, nonatomic) UINavigationController *navigationController;
-(void)buttonPressed;
-(void)getSurveys;
-(void)notificationReceived:(NSNotification *)notification;
@end
