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

@interface PollsViewController ()

@end

@implementation PollsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:@"BUSINESS_SET"
                                                   object:nil];
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
    // Do any additional setup after loading the view from its nib.
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
                                                                    poll_id:[[pollData objectForKey:@"id"] intValue]];
                                
                                // debugging:
                                NSLog(@"Poll results: %@", newPoll.responses);
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
    static NSString *CellIdentifier = @"PollCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( nil == cell ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[(Poll*)[self.polls objectAtIndex:indexPath.section] options] objectAtIndex:indexPath.row];
    
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
                                         poll_id:[[pollDict objectForKey:@"id"] intValue]];
        NSLog(@"Poll created: %@",poll.description);
        
        [polls addObject:poll];
    }
    
    return polls;
}

@end
