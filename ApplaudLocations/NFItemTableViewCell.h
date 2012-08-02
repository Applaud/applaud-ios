//
//  NFItemTableViewCell.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/1/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "NFItem.h"

@interface NFItemTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier newsfeed:(NFItem*)newsfeed;

@property (strong, nonatomic) NFItem *newsfeed;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *bodyLabel;
@property (strong, nonatomic) UIView *containerView;
@property (readonly) CGFloat height;

@end

