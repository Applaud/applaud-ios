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

@interface QuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) Survey *survey;
@property (nonatomic, strong) NSMutableArray *surveyControllers;
@property (weak, nonatomic) IBOutlet UITextView *summaryText;
@property (weak, nonatomic) IBOutlet UITableView *questionsTable;
@property (strong, nonatomic) UINavigationController *navigationController;
- (void)buttonPressed;
@end
