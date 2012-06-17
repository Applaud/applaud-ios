//
//  SurveyFieldViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/17/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurveyField.h"

@interface SurveyFieldViewController : UIViewController
@property (strong, nonatomic) SurveyField *field;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end
