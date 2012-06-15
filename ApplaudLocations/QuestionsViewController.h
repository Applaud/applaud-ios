//
//  QuestionsViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Survey.h"

@interface QuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) Survey *survey;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryText;
@property (weak, nonatomic) IBOutlet UITableView *questionsTable;
@end
