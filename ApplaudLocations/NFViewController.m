//
//  NFViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFViewController.h"
#import "ConnectionManager.h"
#import "AppDelegate.h"

@interface NFViewController ()

@end

@implementation NFViewController

@synthesize appDelegate = _appDelegate;
@synthesize newsFeeds = _newsFeeds;
@synthesize navigationController = _navigationController;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Let us know about updates from the newsfeed.
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newfeedReceived:) name:@"NEWSFEED_RECEIVED" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"BUSINESS_SET" object:nil];
        _newsFeeds = [[NSMutableArray alloc] init];
        [self setTitle:@"Newsfeed"];
    }
    return self;
}

-(void)notificationReceived:(NSNotification *)notification {
    if([notification.name isEqualToString:@"BUSINESS_SET"]) {
        [self getNewsFeeds];
        self.navigationController.navigationBar.tintColor = self.appDelegate.currentBusiness.primaryColor;
        self.tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:self.appDelegate.currentBusiness.secondaryColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _tableView = nil;
    _newsFeeds = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableView data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.newsFeeds.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    // Maximum size of the title/subtitle
    CGSize constraintSize = CGSizeMake(self.view.bounds.size.width 
                                       - 2*CELL_ELEMENT_MARGIN 
                                       - IMAGE_SIZE 
                                       - CELL_PADDING
                                       - 2*CELL_MARGIN, 400);
                                       
                                       
    // Create the image
    UIImageView *imageView = [[UIImageView alloc] 
                              initWithImage:[[[self.newsFeeds objectAtIndex:indexPath.section] image] scaleToSize:IMAGE_SIZE]];
    [imageView setFrame:CGRectMake(CELL_ELEMENT_MARGIN, CELL_ELEMENT_MARGIN, IMAGE_SIZE, IMAGE_SIZE)];
    [cell.contentView addSubview:imageView];
    
    // set the label text to the corresponding NFItem title
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.text = [[self.newsFeeds objectAtIndex:indexPath.section] title];
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = UILineBreakModeWordWrap;
    [textLabel setFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]];
    CGSize titleSize = [[[self.newsFeeds objectAtIndex:indexPath.section] title]
                        sizeWithFont:[UIFont systemFontOfSize:TITLE_SIZE] 
                        constrainedToSize:constraintSize 
                        lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"Title size: %f x %f",titleSize.width,titleSize.height);
    [textLabel setFrame:CGRectMake(CELL_ELEMENT_MARGIN + IMAGE_SIZE + CELL_PADDING, 
                                   CELL_ELEMENT_MARGIN, 
                                   titleSize.width, 
                                   titleSize.height)];
    [cell.contentView addSubview:textLabel];
    
    // set the subtitle text and size
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    detailLabel.text = [[self.newsFeeds objectAtIndex:indexPath.section] subtitle];
    detailLabel.numberOfLines = 0;
    detailLabel.lineBreakMode = UILineBreakModeWordWrap;
    [detailLabel setFont:[UIFont systemFontOfSize:SUBTITLE_SIZE]];
    CGSize detailSize = [[[self.newsFeeds objectAtIndex:indexPath.section] subtitle]
                         sizeWithFont:[UIFont systemFontOfSize:SUBTITLE_SIZE] 
                         constrainedToSize:constraintSize 
                         lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"subtitle size: %f x %f",detailSize.width,detailSize.height);
    [detailLabel setFrame:CGRectMake(CELL_ELEMENT_MARGIN + IMAGE_SIZE + CELL_PADDING, 
                                     CELL_ELEMENT_MARGIN + titleSize.height + CELL_PADDING, 
                                     detailSize.width, 
                                     detailSize.height)];
    [cell.contentView addSubview:detailLabel];
    
    // body teaser
    NSString *bodyTeaserText = [[[self.newsFeeds objectAtIndex:indexPath.section] body] 
                                substringToIndex:MIN(TEASER_LENGTH,
                                                     [[[self.newsFeeds objectAtIndex:indexPath.section] body] length]-1)];
    bodyTeaserText = [NSString stringWithFormat:@"%@...",bodyTeaserText];
    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    bodyLabel.text = bodyTeaserText;
    bodyLabel.numberOfLines = 2;
    bodyLabel.lineBreakMode = UILineBreakModeWordWrap;
    [bodyLabel setFont:[UIFont systemFontOfSize:TEASER_SIZE]];
    CGSize bodySize = [bodyTeaserText
                       sizeWithFont:[UIFont systemFontOfSize:TEASER_SIZE]
                       constrainedToSize:CGSizeMake(self.view.bounds.size.width
                                                    - 2*CELL_MARGIN
                                                    - 2*CELL_PADDING,
                                                    400)
                       lineBreakMode:UILineBreakModeWordWrap];
    [bodyLabel setFrame:CGRectMake(CELL_ELEMENT_MARGIN,
                                   CELL_ELEMENT_MARGIN + titleSize.height + CELL_PADDING + detailSize.height + CELL_PADDING, 
                                   bodySize.width,
                                   bodySize.height)];
    [cell.contentView addSubview:bodyLabel];
    
    return cell;
}

#pragma mark -
#pragma mark UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize constraintSize = CGSizeMake(self.view.bounds.size.width 
                                       - 2*CELL_ELEMENT_MARGIN
                                       - IMAGE_SIZE
                                       - CELL_PADDING
                                       - 2*CELL_MARGIN, 400);
    CGSize sizeRectTitle = [[[self.newsFeeds objectAtIndex:indexPath.section] title] 
                            sizeWithFont:[UIFont systemFontOfSize:TITLE_SIZE]
                            constrainedToSize:constraintSize 
                            lineBreakMode:UILineBreakModeWordWrap];
    CGSize sizeRectSubtitle = [[[self.newsFeeds objectAtIndex:indexPath.section] subtitle] 
                               sizeWithFont:[UIFont systemFontOfSize:SUBTITLE_SIZE] 
                               constrainedToSize:constraintSize
                               lineBreakMode:UILineBreakModeWordWrap];
    NSString *bodyTeaserText = [[[self.newsFeeds objectAtIndex:indexPath.section] body] 
                                substringToIndex:MIN(TEASER_LENGTH,[[[self.newsFeeds objectAtIndex:indexPath.section] body] length]-1)];
    bodyTeaserText = [NSString stringWithFormat:@"%@...",bodyTeaserText];
    CGSize sizeRectBody = [bodyTeaserText
                           sizeWithFont:[UIFont systemFontOfSize:TEASER_SIZE]
                           constrainedToSize:CGSizeMake(self.view.bounds.size.width
                                                        - 2*CELL_MARGIN
                                                        - 2*CELL_PADDING,
                                                        400)
                           lineBreakMode:UILineBreakModeWordWrap];
    return sizeRectTitle.height + sizeRectSubtitle.height + sizeRectBody.height + CELL_PADDING + 3*CELL_ELEMENT_MARGIN;
}

/*
 * create a new detail view controller and show it
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NFItemViewController *nfivc = [[NFItemViewController alloc] initWithNibName:@"NFItemViewController" bundle:nil];
    nfivc.item = [self.newsFeeds objectAtIndex:indexPath.section];
    nfivc.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    nfivc.bodyText.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    [self.navigationController pushViewController:nfivc animated:YES];
}

#pragma mark -
#pragma Other methods


#pragma mark -
#pragma URL connection

/*
 * get newsfeeds from the server.
 * this is called when we load up the news feed is selected
 */
- (void) getNewsFeeds {
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[NSNumber numberWithInt:self.appDelegate.currentBusiness.business_id],
                          @"business_id", nil];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:&error];
    if(error) {
        NSLog(@"%@", error);
    }
    [ConnectionManager serverRequest:@"POST" withData:data url:NEWSFEED_URL callback:^(NSData *data) {
//        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&e];
        
        NSArray *items = [dict objectForKey:@"newsfeed_items"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd hh:mm"];
        for(NSDictionary *feed in items) {
            [self.newsFeeds addObject:[[NFItem alloc] initWithTitle:[feed objectForKey:@"title"]
                                                           subtitle:[feed objectForKey:@"subtitle"]
                                                               body:[feed objectForKey:@"body"]
                                                               date:[format dateFromString:[feed objectForKey:@"date"]]
                                                              image:[UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                                                            [[NSURL alloc] initWithString:
                                                                                             [NSString stringWithFormat:@"%@%@", SERVER_URL, [feed objectForKey:@"image"]]]]]]];
        }
        [self.tableView reloadData];
    }];
}

@end
