//
//  PollOptionCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PollFieldCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) NSString *placeholder;

@end
