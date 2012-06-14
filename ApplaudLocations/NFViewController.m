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
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Let us know about updates from the newsfeed.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newfeedReceived:) name:@"NEWSFEED_RECEIVED" object:nil];
        _newsFeeds = [[NSMutableArray alloc] init];
        /*CGRect labelRect = CGRectMake(0, 0, 320, 50);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, labelRect.size.height + labelRect.origin.y,
                                                                   labelRect.size.width,
                                                                   self.view.bounds.size.height -
                                                                   (labelRect.size.height+labelRect.origin.y))
                                                  style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];*/
    }
    return self;
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
    cell.textLabel.text = [[self.newsFeeds objectAtIndex:indexPath.row] title];
    return cell;
}

#pragma mark -
#pragma UITableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NFItemViewController *nfivc = [[NFItemViewController alloc] initWithNibName:@"NFItemViewController" bundle:nil];
    nfivc.item = [self.newsFeeds objectAtIndex:indexPath.row];
    [self presentViewController:nfivc animated:YES completion:nil];
}

#pragma mark -
#pragma Other methods

- (void) newfeedReceived:(NSNotification *)notification {
    NSArray *feeds = notification.object;
    for(NSDictionary *feed in feeds) {
        [self.newsFeeds addObject:[[NFItem alloc] initWithTitle:[feed objectForKey:@"title"]
                                                       subtitle:[feed objectForKey:@"subtitle"]
                                                           body:[feed objectForKey:@"body"]
                                                           date:[feed objectForKey:@"date"]]];
    }
  [self.tableView reloadData];
}

@end
