//
//  NFItemViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFItem.h"
#import "NFItemTableViewCell.h"

@interface NFItemViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NFItem *item;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
