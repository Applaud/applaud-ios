//
//  MasterViewController.m
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "MasterViewController.h"
#import "NFViewController.h"
#import "EmployeeListViewController.h"
#import "Business.h"
#import "ApplaudProgramSettingsModel.h"
#import "FirstTimeNavigatorViewController.h"
#import "ConnectionManager.h"

@implementation MasterViewController

@synthesize locationsArray, mapViewController, tableView, titleLabel, tabBarController, window=_window;
@synthesize settings = _settings;
@synthesize appDelegate = _appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationsArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(businessReceived:) name:@"BUSINESS_RECEIVED" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinished:) name:@"DOWNLOAD_FINISHED" object:nil];

    }
    return self;
}

- (id)init {
    return [super init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(showMapView)]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"List View";
    self.navigationItem.backBarButtonItem = backButton;
    [self.view addSubview:titleLabel];
    [self.view addSubview:tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.titleLabel = nil;
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( nil == cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    // Configure the cell...
    Business *business = [locationsArray objectAtIndex:indexPath.row];
    [[cell textLabel] setText:business.name];
    [[cell detailTextLabel] setText:business.type];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block Business *bus = [locationsArray objectAtIndex:indexPath.row];
    
    // Show the activity indicator in the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"Checking in at business: %@", bus.description);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          bus.latitude, @"latitude",
                          bus.longitude, @"longitude",
                          bus.goog_id, @"goog_id",
                          bus.name, @"name",
                          nil];

//    NSURL *url = [[NSURL alloc] initWithString:urlString];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"POST";
//    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//    [request addValue:[ConnectionManager getCSRFTokenFromURL:urlString] forHTTPHeaderField:@"X-CSRFToken"];

    NSData *data = [ConnectionManager serverRequest:@"POST" 
                                           withData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil] 
                                                url:CHECKIN_URL
                                           callback:^(NSData *dat){
                                               NSLog(@"here is my checkin data: %@", [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding]);
                                               
                                               // Set app delegate's current business from what was returned by the server
                                               NSLog(@"Business from server: %@",bus.description);
                                               self.appDelegate.currentBusiness = bus;
                                               
                                               
                                               
                                               // Let everyone know that we have a real business now
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"BUSINESS_SET" object:bus];
                                           }];

}


#pragma mark -
#pragma mark Other Methods

- (void)showMapView {
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void) businessReceived:(NSNotification *)notification {
    self.locationsArray = [notification object];
    [tableView reloadData];
}

- (void) downloadFinished:(NSNotification *)notification {
    static int notificationCount = 0;
    notificationCount++;
    
    // N.B. Change this number with how many views must download information from the server
    // on startup.
    if (notificationCount == 4) {
        if ( self.settings.firstTimeLaunching ) {
            FirstTimeNavigatorViewController *ftnvc = [[FirstTimeNavigatorViewController alloc] initWithNibName:@"FirstTimeNavigatorViewControllerIphone" bundle:nil];
            ftnvc.tabBarController = self.tabBarController;
            ftnvc.window = _window;
            _window.rootViewController = ftnvc;
        }
        else {
            // This corresponds to the newsfeed.
            [tabBarController setSelectedIndex:4];
            _window.rootViewController = tabBarController;
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end