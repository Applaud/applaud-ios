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
#define CELL_ELEMENT_MARGIN 10.0f    // space between cell wall and anything else
#define CELL_MARGIN 22.0f           // space between outside of the cell and edge of the screen
#define TITLE_SIZE 18.0f            // size of newsfeed item titles
#define SUBTITLE_SIZE 12.0f         // size of newsfeed item subtitles
#define TEASER_SIZE 14.0f           // size of the teaser text (excerpted from the body)
#define TEASER_LENGTH 60            // number of characters of the body to use for teaser text

@class AppDelegate;

@interface NFViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *newsFeeds;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
-(void)getNewsFeeds;
@end
