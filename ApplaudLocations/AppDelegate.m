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

@implementation AppDelegate

@synthesize window = _window;
@synthesize tracker;
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator, applicationDocumentPath;
@synthesize settings = _settings;
@synthesize currentBusiness = _currentBusiness;
@synthesize masterViewController = _masterViewController;
@synthesize navControl = _navControl;
@synthesize tabNavigator = _tabNavigator;

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
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"%@",error);
    }
    else {
        if ( mutableFetchResults.count == 0 ) {
            // first time launching
            // Create some settings here
            _settings = (ApplaudProgramSettingsModel *)[NSEntityDescription insertNewObjectForEntityForName:@"ApplaudProgramSettings"
                                                                                     inManagedObjectContext:managedObjectContext];
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
    [self.tracker startUpdatingLocation];
    
    [self refreshViewControllers];
    
    // TODO: should figure out how to set UITabBarItem images
    self.masterViewController.tabBarController = self.tabNavigator;
    self.tabNavigator.delegate = self;
    [self.masterViewController setWindow:self.window];
   

    // Setup the window for display
    self.navControl = [[UINavigationController alloc] initWithRootViewController:self.masterViewController];
    self.window.rootViewController = self.navControl;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // We want to be notified about login success or failure
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSucceeded:)
                                                 name:@"LOGIN_SUCCESS"
                                               object:nil];
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
        [loginAlert show];
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark UIAlertView Delegate

/**
 * The user entered in login credentials. Send to the server securely somehow.
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *username = [alertView textFieldAtIndex:0].text;
    NSString *password = [alertView textFieldAtIndex:1].text;
    
    // The OK button
    if ( buttonIndex == 1 ) {
        [ConnectionManager authenticateWithUsername:username password:password];
    }
    // User hit 'cancel'
    else if ( buttonIndex == 0 ) {
        ErrorViewController *evc = [[ErrorViewController alloc] init];
        self.window.rootViewController = evc;
    }
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

    // Set up the tab bar
    UITabBarItem *employeeItem = [[UITabBarItem alloc] initWithTitle:@"Applaud"
                                                               image:[UIImage imageNamed:@"employees"]
                                                                 tag:100];
    elvc.tabBarItem = employeeItem;
    UITabBarItem *questionItem = [[UITabBarItem alloc] initWithTitle:@"Feedback"
                                                               image:[UIImage imageNamed:@"dialog"]
                                                                 tag:101];
    qvc.tabBarItem = questionItem;
    UITabBarItem *newsItem = [[UITabBarItem alloc] initWithTitle:@"News"
                                                           image:[UIImage imageNamed:@"newsfeed"]
                                                             tag:102];
    nfvc.tabBarItem = newsItem;
    self.tabNavigator.viewControllers = @[newsNav, questionNav, employeeNav];
}

-(void)backButtonPressed {
    [self refreshViewControllers];
    self.window.rootViewController = self.navControl;
    [self.masterViewController.tableView deselectRowAtIndexPath:[self.masterViewController.tableView indexPathForSelectedRow]
                                                       animated:NO];
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

#pragma mark -
#pragma mark Login Success/Failure Methods

/*
 * Login was completely successful.
 */
- (void)loginSucceeded:(NSNotification *)notification {
    NSArray *userPassword = notification.object;
    self.settings.username = userPassword[0];
    self.settings.password = userPassword[1];
    NSError *err;
    [self.managedObjectContext save:&err];
}

/*
 * Login failed for some reason (could not connect to server, bad username/password combo)
 */
- (void)loginFailed:(NSNotification *)notification {
    if ( ERROR_NO_CONNECTION == error_code ||
        ERROR_SERVER_ERROR == error_code) {
        ErrorViewController *evc = [[ErrorViewController alloc] init];
        self.window.rootViewController = evc;
    }
    else {
        UIAlertView *tryAgain = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials"
                                                           message:@"Please try again."
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        tryAgain.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [tryAgain show];
    }
}

#pragma mark -
#pragma mark Error Messages

- (void)fatalError:(NSNotification *)notification {
    ErrorViewController *evc = [[ErrorViewController alloc] init];
    self.window.rootViewController = evc;
}

@end
