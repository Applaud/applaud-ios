//
//  SurveyFieldViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/17/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SurveyField.h"
#import "QuestionsViewController.h"

#define WIDGET_HEIGHT 100
#define WIDGET_BEGIN 100

@interface SurveyFieldViewController : UIViewController
@property (strong, nonatomic) SurveyField *field;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) NSMutableArray *labels;
-(NSArray *)getAnswer;
@end
