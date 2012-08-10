//
//  PhotoCommentViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Comment.h"
#import "PhotoCommentCell.h"
#import "BusinessPhoto.h"
#import "ConnectionManager.h"
#import "AppDelegate.h"

@interface PhotoCommentViewController : UIViewController <UITableViewDataSource,
                                                          UITableViewDelegate,
                                                          UITextFieldDelegate>
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) BusinessPhoto *businessPhoto;
@property (strong, nonatomic) UITextField *commentField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) AppDelegate *appDelegate;

-(id)initWithPhoto:(BusinessPhoto *)businessPhoto;
@end
