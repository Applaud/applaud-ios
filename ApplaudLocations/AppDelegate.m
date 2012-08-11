//
//  AppDelegate.m
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/8/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "NFViewController.h"
#import "EmployeeListViewController.h"
#import "QuestionsViewController.h"
#import "ErrorViewController.h"
#import "ConnectionManager.h"
#import "BusinessPhotoViewController.h"
#import "PollsViewController.h"
#import "MingleListViewController.h"
#import "LoginRegisterViewController.h"


@implementation AppDelegate

@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator, applicationDocumentPath;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Listen for fatal errors
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginFailed:)
                                                 name:@"FATAL_ERROR"
                                               object:nil];
    
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    
    //
    // Retrieve program settings
    // 
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ApplaudProgramSettings"
                                              inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];
    
    NSError *error = nil;    
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"%@",error);
    }
    else {
        if ( mutableFetchResults.count == 0 ) {
            // first time launching
            // Create some settings here
            _settings = (ApplaudProgramSettingsModel *)[NSEntityDescription insertNewObjectForEntityForName:@"ApplaudProgramSettings"
                                                                                     inManagedObjectContext:self.managedObjectContext];
            _settings.firstTimeLaunching = YES;
        }
        else {
            _settings = mutableFetchResults[0];
            _settings.firstTimeLaunching = NO;
        }
    }
    
    // List view controller, for selecting the location
    self.masterViewController = [[MasterViewController alloc] init];
    self.masterViewController.appDelegate = self;
    self.masterViewController.settings = self.settings;
    
    // The tab bar, for navigation
    self.tabNavigator = [[UITabBarController alloc] init];
    
    //
    // Set up view controllers and class members
    //
    // The "tracker" updates the NotificationCenter about changes in the user's location
    // Since we want to track this throughout the application, we initialize it here.
    self.tracker = [[BusinessLocationsTracker alloc] init];
    self.tracker.appDelegate = self;
    [self.tracker startUpdatingLocation];
    
    [self refreshViewControllers];
	
    self.masterViewController.tabBarController = self.tabNavigator;
    self.tabNavigator.delegate = self;
    [self.masterViewController setWindow:self.window];
   

    // Setup the window for display
    self.navControl = [[UINavigationController alloc] initWithRootViewController:self.masterViewController];
    self.navControl.navigationBar.tintColor = [UIColor darkGrayColor];
    self.window.rootViewController = self.navControl;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginFailed:)
                                                 name:@"LOGIN_FAILURE"
                                               object:nil];
    
    // Authenticate the user
    NSString *username, *password;
    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login to Applaud"
                                                         message:@"Please enter your login information."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    // Try to retrieve username and password from internal database
    if ( (username = self.settings.username) && (password = self.settings.password) ) {
        // Perform login
        [ConnectionManager authenticateWithUsername:username password:password];
    }
    else {
        LoginRegisterViewController *LRVC = [[LoginRegisterViewController alloc] init];
        LRVC.window = self.window;
        LRVC.appDelegate = self;
        
        UINavigationController *LRNavBar = [[UINavigationController alloc] initWithRootViewController:LRVC];
        
        self.window.rootViewController = LRNavBar;
    }
       
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

/*
 * If there's an error screen up, try to get businesses again.
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if([self.window.rootViewController isKindOfClass:[ErrorViewController class]]) {
        self.masterViewController = [[MasterViewController alloc] init];
        self.masterViewController.appDelegate = self;
        self.masterViewController.settings = self.settings;
		[self.tracker startUpdatingLocation];
		[self refreshViewControllers];
        self.masterViewController.tabBarController = self.tabNavigator;
        self.masterViewController.window = self.window;
        self.navControl.viewControllers = @[self.masterViewController];
        self.window.rootViewController = self.navControl;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma Back button methods

-(void)refreshViewControllers {
    // Creating the view controllers in the tab bar
    // EmployeeListViewController first
    EmployeeListViewController *elvc = [[EmployeeListViewController alloc] init];
    UINavigationController *employeeNav = [[UINavigationController alloc] initWithRootViewController:elvc];
    elvc.navigationController = employeeNav;
    elvc.appDelegate = self;
    
    // Polls view controller
    PollsViewController *pvc = [[PollsViewController alloc] init];
    [pvc setTitle:@"Polls"];
    UINavigationController *pollsNav = [[UINavigationController alloc] initWithRootViewController:pvc];
    pvc.navigationController = pollsNav;
    pvc.appDelegate = self;
    
    // Threads (mingle) view controller
    MingleListViewController *mlvc = [[MingleListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    mlvc.title = @"Mingle";
    UINavigationController *mingleNav = [[UINavigationController alloc] initWithRootViewController:mlvc];
    mlvc.navigationController = mingleNav;
    mlvc.appDelegate = self;
    
    // QuestionsViewController next
    QuestionsViewController *qvc = [[QuestionsViewController alloc] init];
    [qvc setTitle:@"Dialog"];
    UINavigationController *questionNav = [[UINavigationController alloc] initWithRootViewController:qvc];
    qvc.navigationController = questionNav;
    qvc.appDelegate = self;
    
    // And then NFViewController
    NFViewController *nfvc = [[NFViewController alloc] init];
    [nfvc setTitle:@"News Feed"];
    UINavigationController *newsNav = [[UINavigationController alloc] initWithRootViewController:nfvc];
    nfvc.navigationController = newsNav;
    nfvc.appDelegate = self;
    
    // BusinessPhotoViewController
    BusinessPhotoViewController *bpvc = [[BusinessPhotoViewController alloc] init];
    UINavigationController *photoNav = [[UINavigationController alloc] initWithRootViewController:bpvc];
    bpvc.navigationController = photoNav;
    bpvc.title = @"Photos";
    bpvc.appDelegate = self;

    // Set up the tab bar
    UITabBarItem *employeeItem = [[UITabBarItem alloc] initWithTitle:@"Applaud"
                                                               image:[UIImage imageNamed:@"applaud"]
                                                                 tag:100];
    elvc.tabBarItem = employeeItem;
    UITabBarItem *pollsItem = [[UITabBarItem alloc] initWithTitle:@"Polls"
                                                               image:[UIImage imageNamed:@"polls"]
                                                                 tag:101];
    pvc.tabBarItem = pollsItem;
//    UITabBarItem *threadsItem = [[UITabBarItem alloc] init];
//    threadsItem.title = @"Mingle";
    UITabBarItem *threadsItem = [[UITabBarItem alloc] initWithTitle:@"Mingle"
                                                              image:[UIImage imageNamed:@"photos"]
                                                                tag:100];
    mlvc.tabBarItem = threadsItem;
    UITabBarItem *questionItem = [[UITabBarItem alloc] initWithTitle:@"Feedback"
                                                               image:[UIImage imageNamed:@"dialog"]
                                                                 tag:102];
    qvc.tabBarItem = questionItem;
    UITabBarItem *newsItem = [[UITabBarItem alloc] initWithTitle:@"News"
                                                           image:[UIImage imageNamed:@"newsfeed"]
                                                             tag:103];
    nfvc.tabBarItem = newsItem;
    UITabBarItem *photoItem = [[UITabBarItem alloc] initWithTitle:@"Photos"
                                                            image:nil
                                                              tag:104];
    bpvc.tabBarItem = photoItem;
	self.tabNavigator.viewControllers = @[newsNav, pollsNav, mingleNav, employeeNav, photoNav];
}

-(void)backButtonPressed {
    [self refreshViewControllers];
    self.window.rootViewController = self.navControl;
    [self.masterViewController.tableView deselectRowAtIndexPath:[self.masterViewController.tableView indexPathForSelectedRow]
                                                       animated:NO];
    self.tabNavigator.selectedIndex = 0;
}

#pragma mark -
#pragma mark CoreData Methods

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    
    return managedObjectModel;    
}



/**
 
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Applaud.data"]];
    
    NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeUrl
                                                        options:nil
                                                          error:&error]) {
        
    }    

    return persistentStoreCoordinator;
}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}



/*
 * Login failed for some reason (could not connect to server, bad username/password combo)
 *
 */
- (void)loginFailed:(NSNotification *)notification {
    if ( error_code ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"LOGIN_FAILURE"
                                                      object:nil];
        [self fatalError];
    }
}

#pragma mark -
#pragma mark Error Messages

/*
 * This can be used to show the error screen and push it on top of the
 * MasterViewController
 */
- (void)fatalError {
    // Only one error page at a time
    if ( [self.navControl.visibleViewController isKindOfClass:[ErrorViewController class]] )
        return;
    
    ErrorViewController *evc = [[ErrorViewController alloc] init];
    evc.appDelegate = self;
    [self.navControl popToViewController:self.masterViewController animated:NO];
    [self.navControl pushViewController:evc animated:YES];
}

@end
