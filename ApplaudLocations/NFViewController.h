//
//  NFViewController.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessLocationsTracker.h"
#import "NFItemViewController.h"
#import "NFItem.h"
#import "UIImage+Scale.h"

#define IMAGE_SIZE 50.0f            // how big the image is
#define CELL_PADDING 5.0f           // how much space between things inside of the cell
#define CELL_ELEMENT_MARGIN 10.0f   // space between cell wall and anything else
#define CELL_MARGIN 22.0f           // space between outside of the cell and edge of the screen

@class AppDelegate;

@interface NFViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *newsFeeds;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
-(void)getNewsFeeds;
@end
