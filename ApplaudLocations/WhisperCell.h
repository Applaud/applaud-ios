//
//  WhisperCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/10/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface WhisperCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIPlaceHolderTextView *textView;
@property (nonatomic, strong) NSString *placeholder;

@end
