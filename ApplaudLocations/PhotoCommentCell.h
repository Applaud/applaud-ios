//
//  PhotoCommentCell.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

#define CELL_PADDING 10.0f
#define ELEMENT_MARGIN 5.0f
#define COMMENT_SIZE 14.0f
#define NAME_HEIGHT 15.0f

@interface PhotoCommentCell : UITableViewCell
@property (strong, nonatomic) Comment *comment;
@property (strong, nonatomic) UITextView *commentTextView;
@property (strong, nonatomic) UILabel *nameLabel;

-(id)initWithComment:(Comment *)comment style:(UITableViewCellStyle)style
     reuseIdentifier:(NSString *)reuseIdentifier;
@end
