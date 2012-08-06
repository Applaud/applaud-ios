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
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
        cell.textLabel.text = [[self.polls objectAtIndex:indexPath.section] title];
    }
    
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
    NSError *e = [[NSError alloc] init];
    NSArray *pollsData = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&e];
    self.polls = [[NSMutableArray alloc] init];
    
    for ( NSDictionary *pollDict in pollsData ) {
        Poll *poll = [[Poll alloc] initWithTitle:[pollDict objectForKey:@"title"]
                                         options:[pollDict objectForKey:@"options"]
                                       responses:[pollDict objectForKey:@"responses"]
                                     business_id:self.appDelegate.currentBusiness.business_id];
        [self.polls addObject:poll];
    }
}

@end
