//
//  MingleListViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MingleListViewController.h"
#import "ConnectionManager.h"
#import "ThreadPost.h"
#import "MinglePostViewController.h"
#import "NewMingleThreadViewController.h"
#import "MingleThreadCell.h"
#import "User.h"
#import "MingleDisplayConstants.h"

@interface MingleListViewController ()

@end

@implementation MingleListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:@"BUSINESS_SET"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.appDelegate
                                                                            action:@selector(backButtonPressed)];
    
    // New thread button
    UIBarButtonItem *addThreadItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(showNewThread)];
    self.navigationItem.rightBarButtonItem = addThreadItem;
    
    // The toolbar, for sorting Threads
    UISegmentedControl *sortControls = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Newest", @"Popular", @"Liked", nil]];
    UIBarButtonItem	*flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    sortControls.segmentedControlStyle = UISegmentedControlStyleBar;
    sortControls.tintColor = [UIColor grayColor];
    [sortControls addTarget:self action:@selector(sortMethodSelected:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortControls];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.tintColor = [UIColor blackColor];
    self.toolbarWidgets = [[NSMutableArray alloc] initWithObjects:flex, sortItem, flex, nil];
    [self setToolbarItems: self.toolbarWidgets];
    
    // Sort method is "newest"
    sortMethod = SORT_NEWEST;
    [sortControls setSelectedSegmentIndex:SORT_NEWEST];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)notificationReceived:(NSNotification *)notification {
    if([notification.name isEqualToString:@"BUSINESS_SET"]) {
        
        // get thread list
        [self getThreads];
        
        // Set color
        self.view.opaque = YES;
        self.navigationController.navigationBar.tintColor = self.appDelegate.currentBusiness.primaryColor;
        self.tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        self.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Number of threads
    return self.threads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MingleThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.threads[indexPath.row] title]];
    if ( nil == cell ) {
        cell = [[MingleThreadCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:[self.threads[indexPath.row] title]
                                                thread:self.threads[indexPath.row]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set shape and color
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 7.0f;
    
    // Some nice visual FX
    cell.contentView.layer.shadowRadius = 5.0f;
    cell.contentView.layer.shadowOpacity = 0.1f;
    cell.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    cell.contentView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,
                                                                                            0,
                                                                                            cell.frame.size.width,
                                                                                            cell.frame.size.height)
                                                                    cornerRadius:7.0f] CGPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MinglePostViewController *postView = [[MinglePostViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    // Make a new array with the same items. Convert NSArray --> NSMutableArray
    postView.threadPosts = [NSMutableArray arrayWithArray:[self.threads[indexPath.row] threadPosts]];
    
    [self.navigationController pushViewController:postView animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize titleConstraint = CGSizeMake(CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING - MINGLE_RATING_WIDTH - MINGLE_RATING_PADDING, 400);
    CGSize titleSize = [[self.threads[indexPath.row] title] sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]
                                                       constrainedToSize:titleConstraint
                                                           lineBreakMode:UILineBreakModeWordWrap];
    
    return titleSize.height + 70.0f;
}

# pragma mark - Managing Threads

- (IBAction)sortMethodSelected:(id)sender {
    UISegmentedControl *sortControl = (UISegmentedControl*)sender;
    sortMethod = sortControl.selectedSegmentIndex;
    [self refreshThreads];
    [self.tableView reloadData];
}

- (void)getThreads {
    NSDictionary *params = @{ @"business_id" : @(self.appDelegate.currentBusiness.business_id) };
    
    [ConnectionManager serverRequest:@"POST"
                          withParams:params
                                 url:THREADS_URL
                            callback:^(NSHTTPURLResponse *response, NSData *data) {
                                [self handleThreadsData:data];
                            }];
}

- (void)refreshThreads {
    switch (sortMethod) {
        case SORT_LIKED:
            self.threads = threadsSortedLiked;
            break;
        case SORT_POPULAR:
            self.threads = threadsSortedPopular;
            break;
        case SORT_NEWEST:
            self.threads = threadsSortedNewest;
            break;
    }
    [self.tableView reloadData];
}

- (void)sortThreads {
    // Pre-sorting the threads
    threadsSortedLiked = [[NSMutableArray alloc] initWithArray:self.threads];
    threadsSortedPopular = [[NSMutableArray alloc] initWithArray:self.threads];
    threadsSortedNewest = [[NSMutableArray alloc] initWithArray:self.threads];
    [threadsSortedLiked sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Thread *a = (Thread*)obj1;
        Thread *b = (Thread*)obj2;
        int net_rating1 = a.upvotes - a.downvotes;
        int net_rating2 = b.upvotes - b.downvotes;
        if ( net_rating1 < net_rating2 )
            return NSOrderedDescending;
        else if ( net_rating1 > net_rating2 )
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    [threadsSortedNewest sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Thread *a = (Thread*)obj1;
        Thread *b = (Thread*)obj2;
        // We want new --> old ==> ascending
        return [b.date_created compare:a.date_created];
    }];
    [threadsSortedPopular sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Thread *a = (Thread*)obj1;
        Thread *b = (Thread*)obj2;
        if ( a.upvotes + a.downvotes < b.upvotes + b.downvotes )
            return NSOrderedDescending;
        else if ( a.upvotes + a.downvotes > b.upvotes + b.downvotes )
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
}

- (void)handleThreadsData:(NSData*)data {
    NSError *e = nil;
    NSArray *threadsData = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingAllowFragments
                                                             error:&e];

    self.threads = [[NSMutableArray alloc] init];
    NSLog(@"Threads data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy H:m:s";
    for ( NSDictionary *threadData in threadsData ) {
        NSMutableArray *threadPosts = [[NSMutableArray alloc] init];
        
        for ( NSDictionary *dict in threadData[@"posts"] ) {
            ThreadPost *post = [[ThreadPost alloc] initWithBody:dict[@"body"]
                                                   date_created:[formatter dateFromString:dict[@"date_created"]]
                                                        upvotes:[dict[@"upvotes"] intValue]
                                                      downvotes:[dict[@"downvotes"] intValue]
                                                  threadpost_id:[dict[@"id"] intValue]];
            [threadPosts addObject:post];
        }
        
        User *user = [[User alloc] initWithName:[NSString stringWithFormat:@"%@ %@",
                                                 threadData[@"user_creator"][@"first_name"],
                                                 threadData[@"user_creator"][@"last_name"]]
                                       username:threadData[@"user_creator"][@"username"]];
        
        Thread *thread = [[Thread alloc] initWithTitle:threadData[@"title"]
                                          date_created:[formatter dateFromString:threadData[@"date_created"]]
                                               upvotes:[threadData[@"upvotes"] intValue]
                                             downvotes:[threadData[@"downvotes"] intValue]
                                                 posts:threadPosts
                                             thread_id:[threadData[@"id"] intValue]];
        thread.user_creator = user;
        
        [self.threads addObject:thread];
    }
    
    [self sortThreads];
    [self refreshThreads];
}

#pragma mark - New Thread

- (void)showNewThread {
    NewMingleThreadViewController *newThreadView = [[NewMingleThreadViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    newThreadView.view.opaque = YES;
    newThreadView.navigationController.navigationBar.tintColor = self.appDelegate.currentBusiness.primaryColor;
    newThreadView.tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    newThreadView.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    newThreadView.parent = self;
    
    [self.navigationController pushViewController:newThreadView animated:YES];
}

@end
