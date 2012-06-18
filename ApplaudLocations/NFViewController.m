//
//  NFViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFViewController.h"

@interface NFViewController ()

@end

@implementation NFViewController

@synthesize newsFeeds = _newsFeeds;
@synthesize navigationController = _navigationController;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Let us know about updates from the newsfeed.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newfeedReceived:) name:@"NEWSFEED_RECEIVED" object:nil];
        _newsFeeds = [[NSMutableArray alloc] init];
        [self setTitle:@"Newsfeed"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getNewsFeeds];
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, @"/newsfeed"];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *d, NSError *err) {
                               if(err) { // couldn't get data, warn the user
                                   [[[UIAlertView alloc] initWithTitle:@"Connection error"
                                                               message:[err description]
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil] show];
                               }
                               else {
                                   NSError *e = [[NSError alloc] init]; // for debugging, probably not needed anymore
                                   NSDictionary *data = [NSJSONSerialization JSONObjectWithData:d
                                                                                        options:NSJSONReadingAllowFragments
                                                                                          error:&e];
                                   NSArray *items = [data objectForKey:@"newsfeed_items"];
                                   NSDateFormatter *format = [[NSDateFormatter alloc] init];
                                   [format setDateFormat:@"yyyy-MM-dd hh:mm"];
                                   for(NSDictionary *feed in items) {
                                       [self.newsFeeds addObject:[[NFItem alloc] initWithTitle:[feed objectForKey:@"title"]
                                                                                      subtitle:[feed objectForKey:@"subtitle"]
                                                                                          body:[feed objectForKey:@"body"]
                                                                                          date:[format dateFromString:[feed objectForKey:@"date"]]]];
                                   }
                                   [self.tableView reloadData];
                               }
                           }];
}

@end
