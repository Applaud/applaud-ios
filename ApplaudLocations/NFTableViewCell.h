//
//  NFTableViewCell.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/24/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFItem.h"

@interface NFTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier newsfeed:(NFItem*)newsfeed;

@property (strong, nonatomic) NFItem *newsfeed;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *bodyLabel;
@property (strong, nonatomic) UIView *containerView;
@property (readonly) CGFloat height;

@end
