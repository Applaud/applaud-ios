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
#import <QuartzCore/QuartzCore.h>

#define IMAGE_SIZE 50.0f            // how big the image is
#define CELL_ELEMENT_PADDING 5.0f   // how much space between things inside of the cell
#define CELL_PADDING 10.0f          // space between cell wall and anything else
#define CELL_MARGIN 22.0f           // space between outside of the cell and edge of the screen
#define TITLE_SIZE 18.0f            // size of newsfeed item titles
#define SUBTITLE_SIZE 12.0f         // size of newsfeed item subtitles
#define TEASER_SIZE 14.0f           // size of the teaser text (excerpted from the body)
#define TEASER_LENGTH 60            // number of characters of the body to use for teaser text

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
    
    NSLog(@"Number of cells? %d",self.tableView.visibleCells.count);
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = NSDateFormatterLongStyle;
    return [format stringFromDate:[[[self.newsFeeds objectAtIndex:section] objectAtIndex:0] date]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.newsFeeds.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.newsFeeds objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    NFItem *nfItem = [[self.newsFeeds objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // Maximum size of the title/subtitle
    CGSize constraintSize;
    // Left margin of title/subtitle
    int titleLeftMargin = 0;
    if ( nfItem.image ) {
        constraintSize = CGSizeMake(self.view.bounds.size.width 
                                    - 2*CELL_PADDING 
                                    - IMAGE_SIZE 
                                    - CELL_ELEMENT_PADDING
                                    - 2*CELL_MARGIN, 400);
        
        // Create the image
        UIImageView *imageView = [[UIImageView alloc] 
                                  initWithImage:[nfItem.image scaleToSize:IMAGE_SIZE]];
        [imageView setFrame:CGRectMake(CELL_PADDING, CELL_PADDING, IMAGE_SIZE, IMAGE_SIZE)];
        [cell.contentView addSubview:imageView];
        
        titleLeftMargin = CELL_PADDING + IMAGE_SIZE + CELL_ELEMENT_PADDING;
        
    } else {
        constraintSize = CGSizeMake(self.view.bounds.size.width 
                                    - 2*CELL_PADDING
                                    - 2*CELL_MARGIN, 400);
        
        titleLeftMargin = CELL_PADDING;
    }
    
    // set the label text to the corresponding NFItem title
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.text = nfItem.title;
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = UILineBreakModeWordWrap;
    [textLabel setFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]];
    CGSize titleSize = [nfItem.title
                        sizeWithFont:[UIFont systemFontOfSize:TITLE_SIZE] 
                        constrainedToSize:constraintSize 
                        lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"Title size: %f x %f",titleSize.width,titleSize.height);
    [textLabel setFrame:CGRectMake(titleLeftMargin, 
                                   CELL_PADDING,
                                   constraintSize.width,
                                   titleSize.height)];
    [cell.contentView addSubview:textLabel];
    
    // body teaser
    NSString *bodyTeaserText = [nfItem.body
                                substringToIndex:MIN(TEASER_LENGTH,
                                                     nfItem.body.length-1)];
    bodyTeaserText = [NSString stringWithFormat:@"%@...",bodyTeaserText];
    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    bodyLabel.text = bodyTeaserText;
    bodyLabel.numberOfLines = 2;
    bodyLabel.lineBreakMode = UILineBreakModeWordWrap;
    [bodyLabel setFont:[UIFont systemFontOfSize:TEASER_SIZE]];
    CGSize bodyContraintSize = CGSizeMake(self.view.bounds.size.width
                                          - 2*CELL_MARGIN
                                          - 2*CELL_PADDING,
                                          400);
    CGSize bodySize = [bodyTeaserText
                       sizeWithFont:[UIFont systemFontOfSize:TEASER_SIZE]
                       constrainedToSize:bodyContraintSize
                       lineBreakMode:UILineBreakModeWordWrap];
    [bodyLabel setFrame:CGRectMake(CELL_PADDING,
                                   CELL_PADDING + titleSize.height + CELL_ELEMENT_PADDING, 
                                   bodyContraintSize.width,
                                   bodySize.height)];
    [cell.contentView addSubview:bodyLabel];
    
    return cell;
}

#pragma mark -
#pragma mark UITableView delegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set shape and color
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 7.0f;
    
    // Some nice visual FX
    cell.contentView.layer.shadowRadius = 5.0f;
    cell.contentView.layer.shadowOpacity = 0.2f;
    cell.contentView.layer.shadowOffset = CGSizeMake(1, 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize constraintSize;
    NFItem *nfItem = [[self.newsFeeds objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ( nfItem.image ) {
        constraintSize = CGSizeMake(self.view.bounds.size.width 
                                    - 2*CELL_PADDING 
                                    - IMAGE_SIZE 
                                    - CELL_ELEMENT_PADDING
                                    - 2*CELL_MARGIN, 400);        
    } else {
        constraintSize = CGSizeMake(self.view.bounds.size.width 
                                    - 2*CELL_PADDING
                                    - 2*CELL_MARGIN, 400);
    }
    
    CGSize sizeRectTitle = [nfItem.title
                            sizeWithFont:[UIFont systemFontOfSize:TITLE_SIZE]
                            constrainedToSize:constraintSize 
                            lineBreakMode:UILineBreakModeWordWrap];
    NSString *bodyTeaserText = [nfItem.body 
                                substringToIndex:MIN(TEASER_LENGTH,nfItem.body.length-1)];
    bodyTeaserText = [NSString stringWithFormat:@"%@...",bodyTeaserText];
    CGSize sizeRectBody = [bodyTeaserText
                           sizeWithFont:[UIFont systemFontOfSize:TEASER_SIZE]
                           constrainedToSize:CGSizeMake(self.view.bounds.size.width
                                                        - 2*CELL_MARGIN
                                                        - 2*CELL_ELEMENT_PADDING,
                                                        400)
                           lineBreakMode:UILineBreakModeWordWrap];
    return sizeRectTitle.height + sizeRectBody.height + CELL_ELEMENT_PADDING + 2*CELL_PADDING;
}

/*
 * create a new detail view controller and show it
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NFItemViewController *nfivc = [[NFItemViewController alloc] initWithNibName:@"NFItemViewController" bundle:nil];
    nfivc.item = [[self.newsFeeds objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
        NSLog(@"Newsfeeds: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&e];
        
        NSArray *items = [dict objectForKey:@"newsfeed_items"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yyyy"];
        for(NSDictionary *feed in items) {
            UIImage *image = nil;
            NSString *imageURLString = [NSString stringWithFormat:@"%@%@", SERVER_URL, [feed objectForKey:@"image"]];
            if ( imageURLString.length > 0 ) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:imageURLString]]];
            }
                                            
            [self.newsFeeds addObject:[[NFItem alloc] initWithTitle:[feed objectForKey:@"title"]
                                                           subtitle:[feed objectForKey:@"subtitle"]
                                                               body:[feed objectForKey:@"body"]
                                                               date:[format dateFromString:[feed objectForKey:@"date"]]
                                                              image:image]];
        }
     
        // Sort the newsfeeds by date
        [self.newsFeeds sortUsingComparator:^NSComparisonResult(NSObject *a, NSObject *b) {
            if ( [a isKindOfClass:[NFItem class]] && [b isKindOfClass:[NFItem class]] ) {
                NFItem *firstItem = (NFItem*)a;
                NFItem *secondItem = (NFItem*)b;
                
                // Newer dates first
                return [secondItem.date compare:firstItem.date];
            }
            return NSOrderedSame;
        }];
        
        // Group together newsfeeds that came out on the same day
        NSMutableArray *dateBuckets = [[NSMutableArray alloc] init];
        NSDate *prevDate = nil;
        for ( int i=0; i<self.newsFeeds.count; i++ ) {
            if ( 0 == i || ![prevDate isEqualToDate:[[self.newsFeeds objectAtIndex:i] date]] ) {
                prevDate = [[self.newsFeeds objectAtIndex:i] date];
                NSMutableArray *newList = [[NSMutableArray alloc] init];
                [newList addObject:[self.newsFeeds objectAtIndex:i]];
                [dateBuckets addObject:newList];
            }
            else {
                [[dateBuckets objectAtIndex:dateBuckets.count-1] addObject:[self.newsFeeds objectAtIndex:i]];
            }
        }
        self.newsFeeds = dateBuckets;
        
        [self.tableView reloadData];
    }];
}

@end
