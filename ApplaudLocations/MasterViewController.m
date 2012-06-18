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

@implementation MasterViewController

@synthesize locationsArray, mapViewController, tableView, titleLabel, tabBarController, window=_window;
@synthesize settings = _settings;

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
    if ( self.settings.firstTimeLaunching ) {
        FirstTimeNavigatorViewController *ftnvc = [[FirstTimeNavigatorViewController alloc] initWithNibName:@"FirstTimeNavigatorViewControllerIphone" bundle:nil];
        ftnvc.tabBarController = self.tabBarController;
        ftnvc.window = _window;
        _window.rootViewController = ftnvc;
    }
    else {
        // This corresponds to the newsfeed.
        [tabBarController setSelectedIndex:3];
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
