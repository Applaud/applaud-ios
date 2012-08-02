//
//  NFItemViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFItemViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NFDisplayConstants.h"

#define VIEW_PADDING 10.0f
#define ELEMENT_PADDING 10.0f
#define NAVIGATION_GAP 42.0f    // Gap left for the navigationBar of the UINavigationController

@implementation NFItemViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setItem:(NFItem *)item {
    _item = item;
}

/*
 * Set up text for the detail view.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = self.backgroundColor;
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma UITableViewDelegate things

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(nil == cell) {
        cell = [[NFItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier newsfeed:self.item];
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NFItemTableViewCell *cell = (NFItemTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell->_height;
    CGFloat titleSize = [self.item.title sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]
                                  constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 2*CELL_PADDING,
                                                               400)
                                      lineBreakMode:UILineBreakModeWordWrap].height;
    CGFloat bodySize = [self.item.body sizeWithFont:[UIFont boldSystemFontOfSize:TEASER_SIZE]
                                  constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 2*CELL_PADDING,
                                                               400)
                                      lineBreakMode:UILineBreakModeWordWrap].height;
    NSLog(@"cell height: %f", MAX(titleSize, [self.item.imageURL.absoluteString isEqualToString:@""] ? 0 : DETAIL_IMAGE_SIZE) + bodySize + 2*CELL_PADDING + CELL_ELEMENT_PADDING);
    NSLog(@"url: %@", self.item.imageURL.absoluteString);
    return MAX(titleSize, [self.item.imageURL.absoluteString isEqualToString:@""] ? 0 : DETAIL_IMAGE_SIZE) +
               bodySize + 2*CELL_PADDING + CELL_ELEMENT_PADDING;
}

#pragma mark -
#pragma Other methods

/*
 * Deselects the corresponding row in the NFViewController when the back button is pressed.
 */
- (void)viewWillDisappear:(BOOL)animated {
    UINavigationController *parent = (UINavigationController *)self.parentViewController;
    UITableView *parentTableView = [parent.viewControllers[0] tableView];
    NSIndexPath *path = [parentTableView indexPathForSelectedRow];
    [parentTableView deselectRowAtIndexPath:path animated:YES];
}
@end
