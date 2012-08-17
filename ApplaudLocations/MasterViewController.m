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
#import "PollsViewController.h"
#import "MingleListViewController.h"
#import "BusinessPhotoViewController.h"
#import "Business.h"
#import "ApplaudProgramSettingsModel.h"
#import "ConnectionManager.h"

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationsArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(businessReceived:)
                                                     name:@"BUSINESS_RECEIVED"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginSucceeded:)
                                                     name:@"LOGIN_SUCCESS"
                                                   object:nil];
    }
    return self;
}

- (id)init {
    return [super init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                            target:self
                                                                                            action:@selector(refreshButtonPressed)]];
    
    // Background image
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    self.backgroundImage.contentMode = UIViewContentModeBottom;
    self.backgroundImage.frame = self.tableView.frame;
    self.tableView.backgroundView = self.backgroundImage;
    
    self.navigationItem.title = @"Available Locations";
    [self.view addSubview:self.tableView];
    
    // Show our title
    [self setTitle:@"Available Locations"];
    
    // Set our back button (i.e., "back to" this screen)
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.image = [UIImage imageNamed:@"home"];
    backButton.title = @"Apatapa";
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
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
    Business *business = self.locationsArray[indexPath.row];
    cell.textLabel.text = business.name;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block Business *bus = self.locationsArray[indexPath.row];
    // Show the activity indicator in the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSDictionary *dict = @{@"latitude": bus.latitude, @"longitude": bus.longitude,
                           @"goog_id": bus.goog_id, @"name": bus.name,
                           @"types": bus.types};
    NSLog(@"Checking into this bitch: %@",dict);
    [ConnectionManager serverRequest:@"POST"
                            withData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil] 
                                 url:CHECKIN_URL
                            callback:^(NSHTTPURLResponse *r, NSData *dat){
                                // Set app delegate's current business from what was returned by the server
                                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dat options:0 error:nil];
                                NSDictionary *features = dict[@"features"];
                                Business *business = [[Business alloc] initWithName:dict[@"name"]
                                                                            goog_id:dict[@"goog_id"]
                                                                           latitude:dict[@"latitude"]
                                                                          longitude:dict[@"longitude"]
                                                                       primaryColor:dict[@"primary"]
                                                                     secondaryColor:dict[@"secondary"]
                                                                            generic:[dict[@"generic"] boolValue]
                                                                              types:dict[@"types"]];
                                [business setBusiness_id:[dict[@"business_id"] intValue]];
                                self.appDelegate.currentBusiness = business;
                                
                                [self setUpWithApplaud:[features[@"applaud"] intValue]
                                              newsfeed:[features[@"newsfeed"] intValue]
                                                 polls:[features[@"polls"] intValue]
                                                mingle:[features[@"mingle"] intValue]
                                                photos:[features[@"photos"] intValue]];

                                // Listen for when network downloads have stopped.
                                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinished:) name:@"DOWNLOAD_FINISHED" object:nil];
                                
                                // Let everyone know that we have a real business now
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"BUSINESS_SET" object:bus];
                            }];

}


#pragma mark -
#pragma mark Other Methods

-(void)setUpWithApplaud:(BOOL)applaud newsfeed:(BOOL)newsfeed polls:(BOOL)polls mingle:(BOOL)mingle photos:(BOOL)photos{
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    // Creating the view controllers in the tab bar
    if(newsfeed){
        // And then NFViewController
        NFViewController *nfvc = [[NFViewController alloc] init];
        UINavigationController *newsNav = [[UINavigationController alloc] initWithRootViewController:nfvc];
        nfvc.navigationController = newsNav;
        nfvc.appDelegate = self.appDelegate;
        
        UITabBarItem *newsItem = [[UITabBarItem alloc] initWithTitle:@"News"
                                                               image:[UIImage imageNamed:@"newsfeed"]
                                                                 tag:100];
        nfvc.tabBarItem = newsItem;
        
        [viewControllers addObject:newsNav];
    }
    
    if(applaud){
        // EmployeeListViewController first
        EmployeeListViewController *elvc = [[EmployeeListViewController alloc] init];
        UINavigationController *employeeNav = [[UINavigationController alloc] initWithRootViewController:elvc];
        elvc.navigationController = employeeNav;
        elvc.appDelegate = self.appDelegate;
        
        UITabBarItem *employeeItem = [[UITabBarItem alloc] initWithTitle:@"Applaud"
                                                                   image:[UIImage imageNamed:@"applaud"]
                                                                     tag:101];
        elvc.tabBarItem = employeeItem;
        
        [viewControllers addObject:employeeNav];

    }
    
    if(polls){
    
        // Polls view controller
        PollsViewController *pvc = [[PollsViewController alloc] init];
        UINavigationController *pollsNav = [[UINavigationController alloc] initWithRootViewController:pvc];
        pvc.navigationController = pollsNav;
        pvc.appDelegate = self.appDelegate;
        
        UITabBarItem *pollsItem = [[UITabBarItem alloc] initWithTitle:@"Polls"
                                                                image:[UIImage imageNamed:@"polls"]
                                                                  tag:102];
        pvc.tabBarItem = pollsItem;
        
        [viewControllers addObject:pollsNav];
        
    }

    if(mingle){
        // Threads (mingle) view controller
        MingleListViewController *mlvc = [[MingleListViewController alloc] initWithStyle:UITableViewStyleGrouped];
        UINavigationController *mingleNav = [[UINavigationController alloc] initWithRootViewController:mlvc];
        mlvc.navigationController = mingleNav;
        mlvc.appDelegate = self.appDelegate;
        
        UITabBarItem *threadsItem = [[UITabBarItem alloc] initWithTitle:@"Mingle"
                                                                  image:[UIImage imageNamed:@"dialog"]
                                                                    tag:103];
        mlvc.tabBarItem = threadsItem;
        
        [viewControllers addObject:mingleNav];
    }
    
    // BusinessPhotoViewController
    if(photos){
        BusinessPhotoViewController *bpvc = [[BusinessPhotoViewController alloc] init];
        UINavigationController *photoNav = [[UINavigationController alloc] initWithRootViewController:bpvc];
        bpvc.navigationController = photoNav;
        bpvc.title = @"Photos";
        bpvc.appDelegate = self.appDelegate;
        
        UITabBarItem *photoItem = [[UITabBarItem alloc] initWithTitle:@"Photos"
                                                                image:[UIImage imageNamed:@"photos"]
                                                                  tag:104];
        bpvc.tabBarItem = photoItem;
        
        [viewControllers addObject:photoNav];
        
    }
    
    // Set up the tab bar
	self.appDelegate.tabNavigator.viewControllers = (NSArray *)viewControllers;
}


- (void) businessReceived:(NSNotification *)notification {
    self.locationsArray = [notification object];
    
    // debug: add Chambers Landing
    Business *bus = [[Business alloc] initWithName:@"APATAPA HQ"
                                           goog_id:@"8eaccc6443d4a16442baf5f3a0bd527594105436"
                                          latitude:@(39.073778)
                                         longitude:@(-120.141402)
                                      primaryColor:@"#e83723"
                                    secondaryColor:@"#e6d6bc"
                                           generic:NO
                                             types:[NSDictionary dictionaryWithObjectsAndKeys:@"restaurant", @"restaurant", nil]];
    [self.locationsArray addObject:bus];
    
    
    [self.tableView reloadData];
}

-(void)refreshButtonPressed {
    [self.appDelegate.tracker startUpdatingLocation];
}

- (void) downloadFinished:(NSNotification *)notification {
    // Remove our observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DOWNLOAD_FINISHED"
                                                  object:nil];
    
    // 'Default' in tab bar - corresponds to the newsfeed.
    [self.tabBarController setSelectedIndex:0];
    _window.rootViewController = self.tabBarController;
}

- (void)loginSucceeded:(NSNotification*)notification {
    self.tableView.userInteractionEnabled = YES;
}

@end
