//
//  PollsViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PollsViewController.h"
#import "ConnectionManager.h"
#import "Poll.h"
#import "NewPollViewController.h"
#import "PollOptionCell.h"
#import "PollOptionDisplayConstants.h"

@implementation PollsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:@"BUSINESS_SET"
                                                   object:nil];
        cellMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)notificationReceived:(NSNotification *)notification {
    if([notification.name isEqualToString:@"BUSINESS_SET"]) {
        
        // This should get polls
        [self getPolls];
        
        self.view.opaque = YES;
        self.navigationController.navigationBar.tintColor = self.appDelegate.currentBusiness.primaryColor;
        self.tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        self.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set our title
    self.title = @"Polls";
    
    // New poll button
    UIBarButtonItem *newPollItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                 target:self
                                                                                 action:@selector(showNewPoll)];
    self.navigationItem.rightBarButtonItem = newPollItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.appDelegate
                                                                            action:@selector(backButtonPressed)];
    
    // The toolbar, for sorting polls
    UISegmentedControl *sortControls = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Newest", @"Popular", @"Liked", nil]];
    UIBarButtonItem	*flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    sortControls.segmentedControlStyle = UISegmentedControlStyleBar;
    sortControls.tintColor = [UIColor grayColor];
    [sortControls addTarget:self action:@selector(sortMethodSelected:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortControls];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.tintColor = [UIColor blackColor];
    [self setToolbarItems:[NSArray arrayWithObjects:flex,sortItem,flex,nil]];
    
    // Sort method is "newest"
    sortMethod = SORT_NEWEST;
    [sortControls setSelectedSegmentIndex:SORT_NEWEST];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width - 2*CELL_MARGIN - 2*CELL_PADDING - ACCESSORY_SIZE,
                                       400);
    NSString *optionString = [[(Poll*)[self.polls objectAtIndex:indexPath.section] options] objectAtIndex:indexPath.row];
    CGSize optionSize = [optionString sizeWithFont:[UIFont boldSystemFontOfSize:OPTION_TEXT_SIZE]
                                 constrainedToSize:constraintSize
                                     lineBreakMode:UILineBreakModeWordWrap];
    return optionSize.height + 2*CELL_PADDING;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This submits a response
    NSDictionary *response =  @{ @"value" : @(indexPath.row),
                                    @"id" : @([[self.polls objectAtIndex:indexPath.section] poll_id]) };
    
    [ConnectionManager serverRequest:@"POST"
                          withParams:response
                                 url:POLL_SUBMIT_URL
                            callback:^(NSHTTPURLResponse *r, NSData* dat) {
                                NSError *e = [[NSError alloc] init];
                                NSDictionary *pollData = [NSJSONSerialization JSONObjectWithData:dat
                                                                                         options:NSJSONReadingAllowFragments
                                                                                           error:&e];

                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                formatter.dateFormat = @"MM/dd/yyyy H:m:s";
                                Poll *newPoll = [[Poll alloc] initWithTitle:pollData[@"title"]
                                                                    options:pollData[@"options"]
                                                                  responses:pollData[@"responses"]
                                                               date_created:[formatter dateFromString:pollData[@"date_created"]]
                                                                user_rating:[pollData[@"user_rating"] intValue]
                                                               show_results:[pollData[@"show_results"] boolValue]
                                                                    poll_id:[pollData[@"id"] intValue]];
                                // Update the poll
                                self.polls[indexPath.section] = newPoll;
                                
                                for ( int i=0; i<newPoll.responses.count; i++) {
                                    [self showResultAtOptionIndex:i forPoll:newPoll];
                                }
     
                                // Re-sort the polls
                                [self sortPolls];
                                
                                // Deselect this row
                                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                                [self.tableView reloadData];
     }];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.polls objectAtIndex:section] title];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    Poll *poll = self.polls[section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, 0)];
    headerView.backgroundColor = [UIColor clearColor];
    
    CGSize constraintSize, labelSize;
    constraintSize = CGSizeMake(self.view.frame.size.width - 2*CELL_MARGIN - CELL_PADDING - POLL_RATING_PADDING, 400);
    // Cannot uprate or downrate poll when results are showing
    if ( !poll.show_results ) {
        constraintSize = CGSizeMake(constraintSize.width - POLL_RATING_WIDTH, constraintSize.height);
        UISegmentedControl *upDown = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                [UIImage imageNamed:@"downrate"],
                                                                                [UIImage imageNamed:@"uprate"],
                                                                                nil]];
        // Tag the rating widget with the section number (poll index number)
        upDown.tag = section;
        upDown.frame = CGRectMake(constraintSize.width + POLL_RATING_PADDING, CELL_PADDING, POLL_RATING_WIDTH, 32);
        [upDown addTarget:self action:@selector(ratePoll:) forControlEvents:UIControlEventValueChanged];
        [headerView addSubview:upDown];
    }
    
    labelSize = [poll.title sizeWithFont:[UIFont boldSystemFontOfSize:POLL_QUESTION_TEXT_SIZE]
                       constrainedToSize:constraintSize
                           lineBreakMode:UILineBreakModeWordWrap];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, CELL_PADDING, constraintSize.width, labelSize.height)];
    headerTitle.text = poll.title;
    headerTitle.lineBreakMode = UILineBreakModeWordWrap;
    headerTitle.numberOfLines = 0;
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.font = [UIFont boldSystemFontOfSize:POLL_QUESTION_TEXT_SIZE];
    [headerView addSubview:headerTitle];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    Poll *poll = self.polls[section];
    
    CGSize constraintSize, labelSize;
    constraintSize = CGSizeMake(self.view.frame.size.width - 2*CELL_MARGIN - CELL_PADDING - POLL_RATING_PADDING, 400);
    if ( !poll.show_results ) {
        constraintSize = CGSizeMake(constraintSize.width - POLL_RATING_WIDTH, constraintSize.height);
    }
    labelSize = [poll.title sizeWithFont:[UIFont boldSystemFontOfSize:POLL_QUESTION_TEXT_SIZE]
                       constrainedToSize:constraintSize
                           lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 30;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[(Poll*)[self.polls objectAtIndex:section] options] count];
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.polls.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Poll *poll = self.polls[indexPath.section];
    NSString *optionTitle = poll.options[indexPath.row];
    NSString *pollTitle = poll.title;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@%@",pollTitle,optionTitle];
    
    PollOptionCell *cell = (PollOptionCell*)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( nil == cell ){
        cell = [[PollOptionCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
        [cellMap setObject:cell forKey:cellIdentifier];
        if ( poll.show_results ) {
            [self showResultAtOptionIndex:indexPath.row forPoll:poll];
        }

    }
    
    cell.textLabel.text = optionTitle;
    
    return cell;
}

#pragma mark -
#pragma mark Sorting Polls

- (void)refreshPolls {
    switch (sortMethod) {
        case SORT_LIKED:
            self.polls = pollsSortedLiked;
            break;
        case SORT_POPULAR:
            self.polls = pollsSortedPopular;
            break;
        case SORT_NEWEST:
            self.polls = pollsSortedNewest;
            break;
    }
    [self.tableView reloadData];
}

- (void)sortAndReloadPolls {
    [timer invalidate];
    [self sortPolls];
    [self refreshPolls];
}

- (IBAction)sortMethodSelected:(id)sender {
    UISegmentedControl *sortControl = (UISegmentedControl*)sender;
    sortMethod = sortControl.selectedSegmentIndex;
    [self refreshPolls];
    [self.tableView reloadData];
}

- (void)sortPolls {
    // Pre-sorting the polls
    pollsSortedLiked = [[NSMutableArray alloc] initWithArray:self.polls];
    pollsSortedPopular = [[NSMutableArray alloc] initWithArray:self.polls];
    pollsSortedNewest = [[NSMutableArray alloc] initWithArray:self.polls];
    [pollsSortedLiked sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Poll *a = (Poll*)obj1;
        Poll *b = (Poll*)obj2;
        if ( a.user_rating < b.user_rating )
            return NSOrderedDescending;
        else if ( a.user_rating > b.user_rating )
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    [pollsSortedNewest sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Poll *a = (Poll*)obj1;
        Poll *b = (Poll*)obj2;
        // We want new --> old ==> ascending
        return [b.date_created compare:a.date_created];
    }];
    [pollsSortedPopular sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Poll *a = (Poll*)obj1;
        Poll *b = (Poll*)obj2;
        if ( a.total_votes < b.total_votes )
            return NSOrderedDescending;
        else if ( a.total_votes > b.total_votes )
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
}

#pragma mark -
#pragma mark Other Methods

- (void)getPolls {
    NSDictionary *dict = @{@"business_id": @(self.appDelegate.currentBusiness.business_id)};
    
    [ConnectionManager serverRequest:@"POST"
                          withParams:dict
                                 url:POLLS_URL
                            callback: ^(NSHTTPURLResponse *r, NSData *d) {
                                NSLog(@"Poll data: %@",[[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]);
                                [self handlePollsData:d];
                            }];
}

- (void)handlePollsData:(NSData*)data {
    // Grabbing the JSON data from the server's response
    self.polls = [self pollsFromJSON:data];
    
    [self sortPolls];
    
    [self.tableView reloadData];
}
    
- (NSMutableArray*)pollsFromJSON:(NSData*)JSONData {
    NSError *e = [[NSError alloc] init];
    NSArray *pollsData = [NSJSONSerialization JSONObjectWithData:JSONData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&e];
    
    NSMutableArray *polls = [[NSMutableArray alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy H:m:s";
    for ( NSDictionary *pollDict in pollsData ) {
        Poll *poll = [[Poll alloc] initWithTitle:pollDict[@"title"]
                                         options:pollDict[@"options"]
                                       responses:pollDict[@"responses"]
                                    date_created:[formatter dateFromString:pollDict[@"date_created"]]
                                     user_rating:[pollDict[@"user_rating"] intValue]
                                    show_results:[pollDict[@"show_results"] boolValue]
                                         poll_id:[pollDict[@"id"] intValue]];
        [polls addObject:poll];
    }
    
    return polls;
}

- (void)showResultAtOptionIndex:(int)index forPoll:(Poll*)poll {
    double optionVoteCount = [poll.responses[index][@"count"] doubleValue];
    NSString *optionTitle = poll.responses[index][@"title"];
    double value = poll.total_votes? optionVoteCount / poll.total_votes : poll.total_votes;
    PollOptionCell *cell = [cellMap objectForKey:[NSString stringWithFormat:@"%@%@",
                                                  poll.title,
                                                  optionTitle]];
    // Display percentage in the cell
    cell.value = value;
    [cell showResult];
}

- (void)showNewPoll {
    NewPollViewController *npvc = [[NewPollViewController alloc] init];
    npvc.appDelegate = self.appDelegate;
    npvc.pollsViewController = self;
    npvc.tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    [self.navigationController pushViewController:npvc
                                         animated:YES];
}

- (IBAction)ratePoll:(id)sender {
    UISegmentedControl *upDown = (UISegmentedControl*)sender;
    Poll *poll = self.polls[upDown.tag];
    
    // Upvote
    if ( upDown.selectedSegmentIndex ) {
        poll.user_rating++;
    }
    // Downvote
    else {
        poll.user_rating--;
    }
    
    [ConnectionManager serverRequest:@"POST"
                          withParams:  @{@"id" : @(poll.poll_id),
                                @"user_rating" : @(poll.user_rating)}
                                 url:POLL_RATE_URL
                            callback:^(NSHTTPURLResponse *response, NSData *data) {
                                [self sortPolls];
                                [self refreshPolls];
                            }];
}

@end
