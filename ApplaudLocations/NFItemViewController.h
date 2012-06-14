//
//  NFItemViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFItem.h"

@interface NFItemViewController : UIViewController
@property (nonatomic, strong) NFItem *item;
@property IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
- (IBAction)buttonPressed:(id)sender;
@end
