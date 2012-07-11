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

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor lightGrayColor];
      self.locationsArray = [[NSMutableArray alloc] init];
        CGRect labelRect = CGRectMake(0, 0, 320, 50);
        tableView = [[UITableView alloc] 
                     initWithFrame:CGRectMake(0, labelRect.size.height + labelRect.origin.y,
                                              labelRect.size.width,
                                              self.view.bounds.size.height - (labelRect.size.height+labelRect.origin.y))
                     style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        titleLabel = [[UILabel alloc] 
                      initWithFrame:labelRect];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.text = @"Available Locations";
        titleLabel.backgroundColor = [UIColor blackColor];
        titleLabel.textColor = [UIColor whiteColor];
        [self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(showMapView)]];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = @"List View";
        self.navigationItem.backBarButtonItem = backButton;
        [self.view addSubview:titleLabel];
        [self.view addSubview:tableView];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(businessReceived:) name:@"BUSINESS_RECEIVED" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return locationsArray.count;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block Business *bus = [locationsArray objectAtIndex:indexPath.row];
    
    NSLog(@"Checking in at business: %@", bus.description);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          bus.latitude, @"latitude",
                          bus.longitude, @"longitude",
                          bus.goog_id, @"goog_id",
                          bus.name, @"name",
                          nil];
/*    [ConnectionManager serverRequest:@"POST" withParams:dict url:CHECKIN_URL callback:^(NSData *data) {
        NSLog(@"here is my checkin data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *err = nil;
        NSDictionary *busDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if ( err ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checkin Error"
                                                            message:err.description 
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            bus = [[Business alloc] initWithName:[busDict objectForKey:@"name"]
                                            type:bus.type
                                     business_id:[[busDict objectForKey:@"business_id"] intValue]
                                        latitude:[busDict objectForKey:@"latitude"]
                                       longitude:[busDict objectForKey:@"longitude"]];
            
            // Set app delegate's current business from what was returned by the server
            NSLog(@"Business from server: %@",bus.description);
            self.appDelegate.currentBusiness = bus;
        }
    }];*/
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@", SERVER_URL, CHECKIN_URL];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [request addValue:[ConnectionManager getCSRFTokenFromURL:urlString] forHTTPHeaderField:@"X-CSRFToken"];
    NSError *err;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
    NSLog(@"here is my checkin data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    // NSError *e = nil;
    // NSDictionary *busDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
    if ( err ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checkin Error"
                                                        message:err.description 
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
/*        bus = [[Business alloc] initWithName:[busDict objectForKey:@"name"]
                                        type:bus.type
                                 business_id:[[busDict objectForKey:@"business_id"] intValue]
                                    latitude:[busDict objectForKey:@"latitude"]
                                   longitude:[busDict objectForKey:@"longitude"]];*/
        bus = [self.locationsArray objectAtIndex:indexPath.row];
        
        // Set app delegate's current business from what was returned by the server
        NSLog(@"Business from server: %@",bus.description);
        self.appDelegate.currentBusiness = bus;
        // Let everyone know that we have a real business now
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BUSINESS_SET" object:bus];
    }
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

@end
