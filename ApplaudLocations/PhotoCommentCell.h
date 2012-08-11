//
//  PhotoCommentCell.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApatapaDateFormatter.h"
#import "MingleDisplayConstants.h"
#import "Comment.h"

@interface PhotoCommentCell : UITableViewCell
@property (strong, nonatomic) Comment *comment;
@property (strong, nonatomic) UITextView *commentTextView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;

-(id)initWithComment:(Comment *)comment style:(UITableViewCellStyle)style
     reuseIdentifier:(NSString *)reuseIdentifier;
@end
