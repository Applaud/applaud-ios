//
//  GeneralFeedbackViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/17/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralFeedbackViewController : UIViewController
@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)doneEditing:(id)sender;
@end
