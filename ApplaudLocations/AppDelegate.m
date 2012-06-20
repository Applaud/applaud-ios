//
//  AppDelegate.m
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/8/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "MasterViewController.h"
#import "NFViewController.h"
#import "EmployeeListViewController.h"
#import "QuestionsViewController.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize tracker;
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator, applicationDocumentPath;
@synthesize settings = _settings;
@synthesize facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{ 
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    
    //
    // Retrieve program settings
    // 
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ApplaudProgramSettings" inManagedObjectContext:[self managedObjectContext]];
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
            _settings = (ApplaudProgramSettingsModel *)[NSEntityDescription insertNewObjectForEntityForName:@"ApplaudProgramSettings" inManagedObjectContext:managedObjectContext];
            _settings.firstTimeLaunching = YES;
        }
        else {
            _settings = [mutableFetchResults objectAtIndex:0];
            _settings.firstTimeLaunching = NO;
        }
    }
    
    

    //
    // Set up view controllers and class members
    //
    // The "tracker" updates the NotificationCenter about changes in the user's location
    // Since we want to track this throughout the application, we initialize it here.
    self.tracker = [[BusinessLocationsTracker alloc] init];
    
    
    // Map view, for finding user location
    MapViewController *mapViewController = [[MapViewController alloc] init];
    
    // List view controller, for selecting the location
    MasterViewController *masterViewController = [[MasterViewController alloc] init];
    masterViewController.mapViewController = mapViewController;
    masterViewController.settings = self.settings;
    // The tab bar, for navigation
    UITabBarController *tabNavigator = [[UITabBarController alloc] init];
    
    // Creating the view controllers in the tab bar
    // EmployeeListViewController first
    EmployeeListViewController *elvc = [[EmployeeListViewController alloc] init];
    UINavigationController *employeeNav = [[UINavigationController alloc] initWithRootViewController:elvc];
    elvc.navigationController = employeeNav;
    
    // QuestionsViewController next
    QuestionsViewController *qvc = [[QuestionsViewController alloc] init];
    [qvc setTitle:@"Dialog"];
    UINavigationController *questionNav = [[UINavigationController alloc] initWithRootViewController:qvc];
    qvc.navigationController = questionNav;
    
    // And then NFViewController
    NFViewController *nfvc = [[NFViewController alloc] init];
    [nfvc setTitle:@"News Feed"];
    UINavigationController *newsNav = [[UINavigationController alloc] initWithRootViewController:nfvc];
    nfvc.navigationController = newsNav;
	
	// Finally GeneralFeedbackViewController
	GeneralFeedbackViewController *gfvc = [[GeneralFeedbackViewController alloc] init];
	[gfvc setTitle:@"Leave Comment"];
	UINavigationController *generalNav = [[UINavigationController alloc] initWithRootViewController:gfvc];
	gfvc.navigationController = generalNav;
	
    tabNavigator.viewControllers = [NSArray arrayWithObjects:
                                    employeeNav,
                                    [[UIViewController alloc] init],    // This is a dummy!!
									generalNav,
                                    questionNav,
                                    newsNav,
                                    nil];
    // TODO: should figure out how to set UITabBarItem images
    masterViewController.tabBarController = tabNavigator;
    tabNavigator.delegate = self;
    [masterViewController setWindow:self.window];
   
    // Ipad initialization
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ) {
        NSArray *viewControllers = [NSArray arrayWithObjects:masterViewController, mapViewController, nil];
        UISplitViewController *splitView = [[UISplitViewController alloc] init];
        splitView.viewControllers = viewControllers;
        self.window.rootViewController = splitView;
    }
    // Iphone initialization 
    else {
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        self.window.rootViewController = navControl;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    
    // Facebook login: create instance of facebook class
    facebook = [[Facebook alloc] initWithAppId:@"257939124306263" andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![facebook isSessionValid]) {
        [facebook authorize:nil];
    }
    
    
    // Facebook logout call button
    // Add the logout button
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logoutButton.frame = CGRectMake(10, 25, 70, 35);
    [logoutButton setTitle:@"Log Out" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutButtonClicked)
           forControlEvents:UIControlEventTouchUpInside];
    // need to display logoutButton
    [self.window.rootViewController.view addSubview:logoutButton];
    

    
    // Authenticate the user
    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login to Applaud" message:@"Please enter your login information." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [loginAlert show];
    
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
#pragma mark Tabbar delegate

/*
 * make sure we can't select the empty view controller in the space between evaluations and everything else
 */
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if([viewController isEqual:[tabBarController.viewControllers objectAtIndex:1]])
        return NO;
    return YES;
}

#pragma mark -
#pragma mark UIAlertView Delegate

/**
 * The user entered in login credentials. Send to the server securely somehow.
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // The OK button
    if ( buttonIndex == 1 ) {
        NSString *username = [alertView textFieldAtIndex:0].text;
        NSString *password = [alertView textFieldAtIndex:1].text;
        NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, @"/accounts/login/"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
        [request setHTTPBody:[NSData dataWithBytes:[postString UTF8String] length:postString.length]];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        
        if ( connection ) {
            connectionData = [[NSMutableData alloc] init];
        }
        
//        NSLog(@"username:%@, password:%@",username,password);
        
        // Cache username and password in our program settings
        [self.settings setUsername:username];
        [self.settings setPassword:password];
        
        NSError *error = nil;
        if (! [managedObjectContext save:&error] ) {
            NSLog(@"%@", error);
        }
    }
    // User hit 'cancel'
    else if ( buttonIndex == 0 ) {
        NSLog(@"User did not authenticate. Exiting...");
        exit(0);
    }
}


// Redirecting the user to the facebook app for login
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

// Saves the user credentials, ie facebook access token and expiration date.
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}



// Method that gets called when the Facebook logout button is pressed
- (void) logoutButtonClicked:(id)sender {
    [facebook logout];
}


// Remove saved authorization information if it exists
- (void) fbDidLogout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin: (BOOL) cancelled{}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt{}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated{}


#pragma mark -
#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSLog(@"%@", [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding]);
    connectionData = nil;
    // proceed with application based on whether authentication worked or not.
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
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Applaud.data"]];
    
    NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"Could not initiate a persistent store for some reason. %@", error);
        // Handle the error.
    }    

    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

- (void)saveContext {
    
}

@end
