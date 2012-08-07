//
//  PollSubmitCancelCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SubmitCancelDelegate <NSObject>

@required
-(void)submitButtonPressed;
-(void)cancelButtonPressed;

@end

@interface PollSubmitCancelCell : UITableViewCell

@property (nonatomic, strong) UISegmentedControl *submitCancel;
@property (weak) id<SubmitCancelDelegate> delegate;

- (IBAction)segmentSelected:(id)sender;
- (IBAction)segmentDeselected:(id)sender;

@end