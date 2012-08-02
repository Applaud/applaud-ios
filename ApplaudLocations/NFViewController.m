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
#import "NFTableViewCell.h"
#import "NFDisplayConstants.h"
#import <QuartzCore/QuartzCore.h>

#define NO_NEWSFEED_MESSAGE @"This business doesn't have any news items yet. Check back later!"
#define GENERIC_MESSAGE_1 @"Welcome to the Newsfeed! You can find everything from upcoming events to daily deals posted here."
#define GENERIC_MESSAGE_2 [NSString stringWithFormat:@"%@%@%@",@"If learning about new offers and events interests you, tell ",self.appDelegate.currentBusiness.name,@" to start using this feature of Apatapa!"]

@implementation NFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Let us know about updates from the newsfeed.
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newfeedReceived:) name:@"NEWSFEED_RECEIVED" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:@"BUSINESS_SET"
                                                   object:nil];
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonPressed)];
}

-(void)backButtonPressed {
    [self.appDelegate backButtonPressed];
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
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma mark UITableView data source methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.newsFeeds.count == 0) {
        return @"";
    }
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = NSDateFormatterLongStyle;
    return [format stringFromDate:[self.newsFeeds[section][0] date]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.newsFeeds.count == 0) {
        return 1;
    }
    return self.newsFeeds.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( self.appDelegate.currentBusiness.generic )
        return 2;
    else if(self.newsFeeds.count == 0)
        return 1;
    return [self.newsFeeds[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NewsfeedCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( nil == cell ) {
        // Business is a generic
        if ( self.appDelegate.currentBusiness.generic ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:TEASER_SIZE];
            
            // Set the message and photo
            switch ( indexPath.row ) {
                case 0:
                {
                    cell.textLabel.text = GENERIC_MESSAGE_1;
                    UIImage *logoImage = [UIImage imageNamed:@"logo"];
                    float scaleFactor = logoImage.size.width * logoImage.scale / IMAGE_SIZE;
                    cell.imageView.image = [UIImage imageWithCGImage:logoImage.CGImage
                                                               scale:scaleFactor
                                                         orientation:UIImageOrientationUp];
                    cell.imageView.layer.cornerRadius = 5.0f;
                    cell.imageView.layer.masksToBounds = YES;
                }
                    break;
                case 1:
                    cell.textLabel.text = GENERIC_MESSAGE_2;
                    break;
            }

        }
        // Registered business
        else {
            if (self.newsFeeds.count == 0) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.text = NO_NEWSFEED_MESSAGE;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else {
                cell = [[NFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cellIdentifier
                                                     newsfeed:self.newsFeeds[indexPath.section][indexPath.row]];
            }
        }
    }
    else if([cell isKindOfClass:[UITableViewCell class]] &&
            self.newsFeeds.count != 0) {
        cell = [[NFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier
                                             newsfeed:self.newsFeeds[indexPath.section][indexPath.row]];
    }
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
    cell.contentView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,
                                                                                            0,
                                                                                            cell.frame.size.width,
                                                                                            cell.frame.size.height)
                                                                    cornerRadius:7.0f] CGPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Generic newsfeed cells
    if ( self.appDelegate.currentBusiness.generic ) {
        switch ( indexPath.row ) {
            case 0:
                return MAX(IMAGE_SIZE, [GENERIC_MESSAGE_1 sizeWithFont:[UIFont systemFontOfSize:TEASER_SIZE]
                                                     constrainedToSize:CGSizeMake(300, 1000)
                                                         lineBreakMode:UILineBreakModeWordWrap].height) + 2*CELL_PADDING;
                break;
            case 1:
                return [GENERIC_MESSAGE_2 sizeWithFont:[UIFont systemFontOfSize:TEASER_SIZE]
                                     constrainedToSize:CGSizeMake(300, 1000)
                                         lineBreakMode:UILineBreakModeWordWrap].height + 2*CELL_PADDING;
                break;
        }
        
    }
    // Return the number of lines we'll need, plus a bit of padding.
    if(self.newsFeeds.count == 0) {
        return [NO_NEWSFEED_MESSAGE sizeWithFont:[UIFont systemFontOfSize:20.0f]
                                 constrainedToSize:CGSizeMake(300, 1000)
                                     lineBreakMode:UILineBreakModeWordWrap].height + 20;
    }
    CGSize constraintSize;
    NFItem *nfItem = self.newsFeeds[indexPath.section][indexPath.row];
    if ( ! [[nfItem.imageURL absoluteString] isEqualToString:@""] ) {
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
    NFItem *item = self.newsFeeds[indexPath.section][indexPath.row];
    return MAX(sizeRectTitle.height, [item.imageURL.absoluteString isEqualToString:@""] ? 0 : IMAGE_SIZE)
               + sizeRectBody.height + CELL_ELEMENT_PADDING + 2*CELL_PADDING;
}

/*
 * create a new detail view controller and show it
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // No newsfeeds, don't do anything.
    if(self.newsFeeds.count == 0 ) {
        return;
    }
    NFItemViewController *nfivc = [[NFItemViewController alloc] init];
    nfivc.item = self.newsFeeds[indexPath.section][indexPath.row];
    nfivc.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    [self.navigationController pushViewController:nfivc animated:YES];
}

#pragma mark -
#pragma Other methods

/*
 * get newsfeeds from the server.
 * this is called when we load up the news feed is selected
 */
- (void) getNewsFeeds {
    NSDictionary *dict = @{@"business_id": @(self.appDelegate.currentBusiness.business_id)};
    NSError *error = nil;
    if(error) {
        NSLog(@"%@", error);
    }
    [ConnectionManager serverRequest:@"POST" withParams:dict url:NEWSFEED_URL callback:^(NSHTTPURLResponse *r, NSData *data) {
        NSLog(@"Newsfeeds: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&e];
        NSArray *items = dict[@"newsfeed_items"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        
        // Get rid of any old newsfeeds.
        self.newsFeeds = [[NSMutableArray alloc] init];

        [format setDateFormat:@"MM/dd/yyyy"];
        for ( NSDictionary *feed in items ) {
            NSString *imageURLString = @"";
            if (! [[feed objectForKey:@"image"] isEqualToString:@""] ) {
                imageURLString = [NSString stringWithFormat:@"%@%@", SERVER_URL, feed[@"image"]];
            }
            [self.newsFeeds addObject:[[NFItem alloc] initWithTitle:feed[@"title"]
                                                           subtitle:feed[@"subtitle"]
                                                               body:feed[@"body"]
                                                               date:[format dateFromString:feed[@"date"]]
                                                           imageURL:[NSURL URLWithString:imageURLString]]];
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
            if ( 0 == i || ![prevDate isEqualToDate:[self.newsFeeds[i] date]] ) {
                prevDate = [self.newsFeeds[i] date];
                NSMutableArray *newList = [[NSMutableArray alloc] init];
                [newList addObject:self.newsFeeds[i]];
                [dateBuckets addObject:newList];
            }
            else {
                [[dateBuckets objectAtIndex:dateBuckets.count-1] addObject:self.newsFeeds[i]];
            }
        }
        self.newsFeeds = dateBuckets;
        [self.tableView reloadData];
    }];
}

@end
