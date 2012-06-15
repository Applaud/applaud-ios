//
//  MasterViewController.m
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "MasterViewController.h"
#import "NFViewController.h"
#import "Business.h"

@implementation MasterViewController

@synthesize locationsArray, mapViewController, tableView, titleLabel, tabBarController, window=_window;

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
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(businessRecieved:) name:@"BUSINESS_RECIEVED" object:nil];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    // This corresponds to the newsfeed.
    [tabBarController setSelectedIndex:3];
    [self getNewsFeeds];
    _window.rootViewController = tabBarController;
}

#pragma mark -
#pragma URL connection

/*
 * get newsfeeds from the server.
 * this is called when we load up the news feed is selected
 */
- (void) getNewsFeeds {
//    NSURL *url = [[NSURL alloc] initWithString:@"http://ec2-107-22-6-55.compute-1.amazonaws.com/newsfeed"];
    NSURL *url = [[NSURL alloc] initWithString:@"http://127.0.0.1:8000/newsfeed"];
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
                                   // tell the world we have new data
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWSFEED_RECEIVED"
                                                                                       object:items
                                                                                     userInfo:nil];
                               }
                           }];
}

#pragma mark -
#pragma mark Other Methods

- (void)showMapView {
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void) businessRecieved:(NSNotification *)notification {
    self.locationsArray = [notification object];
    [tableView reloadData];
}

@end
