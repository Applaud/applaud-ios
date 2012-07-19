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
    // Do any additional setup after loading the view from its nib.
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
#pragma UITableView data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsFeeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.editing = NO;
    }
    // set the label text to the corresponding NFItem title
    cell.textLabel.text = [[self.newsFeeds objectAtIndex:indexPath.row] title];
    cell.imageView.image = [[[self.newsFeeds objectAtIndex:indexPath.row] image] scaleToSize:35.0];
    cell.contentView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    cell.textLabel.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    cell.detailTextLabel.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    return cell;
}

#pragma mark -
#pragma UITableView delegate methods

/*
 * create a new detail view controller and show it
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NFItemViewController *nfivc = [[NFItemViewController alloc] initWithNibName:@"NFItemViewController" bundle:nil];
    nfivc.item = [self.newsFeeds objectAtIndex:indexPath.row];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_FINISHED" object:nil];
    }];
}

@end
