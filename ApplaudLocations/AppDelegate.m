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
#import "ConnectionManager.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tracker;
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator, applicationDocumentPath;
@synthesize settings = _settings;
@synthesize currentBusiness = _currentBusiness;

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
    masterViewController.appDelegate = self;
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
    qvc.appDelegate = self;
    
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
    gfvc.appDelegate = self;
	
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
    NSString *username = [alertView textFieldAtIndex:0].text;
    NSString *password = [alertView textFieldAtIndex:1].text;
    
    // The OK button
    if ( buttonIndex == 1 ) {
        NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
        NSString *csrfToken = [ConnectionManager getCSRFTokenFromURL:[NSString stringWithFormat:@"%@%@", SERVER_URL, @"/csrf/"]];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, @"/accounts/mobilelogin/"]]];
        [request setHTTPBody:[NSData dataWithBytes:[postString UTF8String] length:postString.length]];
        // Put the CSRF token into the HTTP request. Kinda important.
        [request addValue:csrfToken forHTTPHeaderField:@"X-CSRFToken"];
        [request setHTTPMethod:@"POST"];
        
        NSError *error = nil;
        __block NSString *cookieString = nil;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
                                   NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
                                   if ( err ) {
                                       NSLog(@"login error: %@",error.description);
                                       NSLog(@"LOGIN: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   }
                                   else {
                                       if ( 200 == r.statusCode ) {
                                           NSLog(@"%@",@"Login success!");
                                           NSError *regexError = nil;
                                           cookieString = [r.allHeaderFields objectForKey:@"Set-Cookie"];
                                           NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"sessionid=[a-f0-9]+;"
                                                                                                                  options:0
                                                                                                                    error:&regexError];
                                           NSRange regexRange = [regex rangeOfFirstMatchInString:cookieString
                                                                                         options:0
                                                                                           range:NSMakeRange(0, cookieString.length)];
                                           // Finds the sessionID in the cookie string
                                           cookieString = [cookieString substringWithRange:regexRange];
                                           [[ConnectionManager staticInstance] setSessionCookie:cookieString];
                                           NSLog(@"%@", cookieString);
                                       }
                                       else {
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Login credentials invalid." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                           [alert show];
                                           
                                           //TODO: Repeat login sequence until success or cancel.
                                       }
                                   }
                               }];
        
        if (error)
            NSLog(@"%@", error.description);
        
        // Cache username and password in our program settings
        [self.settings setUsername:username];
        [self.settings setPassword:password];

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
