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
        totalsMap = [[NSMutableDictionary alloc] init];
        percentageMap = [[NSMutableDictionary alloc] init];
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
                                
                                Poll *newPoll = [[Poll alloc] initWithTitle:[pollData objectForKey:@"title"]
                                                                    options:[pollData objectForKey:@"options"]
                                                                  responses:[pollData objectForKey:@"responses"]
                                                               show_results:[[pollData objectForKey:@"show_results"] boolValue]
                                                                    poll_id:[[pollData objectForKey:@"id"] intValue]];
                                
                                for ( int i=0; i<newPoll.responses.count; i++) {
                                    [self showResultAtOptionIndex:i forPoll:newPoll];
                                }
     
                                // Deselect this row
                                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     }];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.polls objectAtIndex:section] title];
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
        [cellMap setObject:cell forKey:[NSString stringWithFormat:@"%@%@",
                                        pollTitle,
                                        optionTitle]];
        if ( poll.show_results ) {
            [self showResultAtOptionIndex:indexPath.row forPoll:poll];
        }

    }
    
    cell.textLabel.text = optionTitle;
    
    return cell;
}

#pragma mark -
#pragma mark Other Methods

- (void)getPolls {
    NSDictionary *dict = @{@"business_id": @(self.appDelegate.currentBusiness.business_id)};
    
    [ConnectionManager serverRequest:@"POST"
                          withParams:dict
                                 url:POLLS_URL
                            callback: ^(NSHTTPURLResponse *r, NSData *d) {
                                [self handlePollsData:d];
                                NSLog(@"Poll data: %@",[[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]);
                            }];
}

- (void)handlePollsData:(NSData*)data {
    // Grabbing the JSON data from the server's response
    self.polls = [self pollsFromJSON:data];
    
    [self.tableView reloadData];
}
    
- (NSMutableArray*)pollsFromJSON:(NSData*)JSONData {
    NSError *e = [[NSError alloc] init];
    NSArray *pollsData = [NSJSONSerialization JSONObjectWithData:JSONData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&e];
    
    NSMutableArray *polls = [[NSMutableArray alloc] init];
    
    for ( NSDictionary *pollDict in pollsData ) {
        Poll *poll = [[Poll alloc] initWithTitle:[pollDict objectForKey:@"title"]
                                         options:[pollDict objectForKey:@"options"]
                                       responses:[pollDict objectForKey:@"responses"]
                                    show_results:[[pollDict objectForKey:@"show_results"] boolValue]
                                         poll_id:[[pollDict objectForKey:@"id"] intValue]];
        NSLog(@"Poll created: %@",poll.description);
        
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
    [self.navigationController pushViewController:npvc
                                         animated:YES];
}

@end
