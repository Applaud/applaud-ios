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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{ 
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // The "tracker" updates the NotificationCenter about changes in the user's location
    // Since we want to track this throughout the application, we initialize it here.
    self.tracker = [[BusinessLocationsTracker alloc] init];
    
    // Map view, for finding user location
    MapViewController *mapViewController = [[MapViewController alloc] init];
    
    // List view controller, for selecting the location
    MasterViewController *masterViewController = [[MasterViewController alloc] init];
    masterViewController.mapViewController = mapViewController;
    
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
    
    // Authenticate the user
/*    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login to Applaud" message:@"Please enter your login information." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [loginAlert show];
    */
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
        NSString *urlString = [NSString stringWithFormat:SERVER_URL, @"/accounts/login"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
        [request setHTTPBody:[NSData dataWithBytes:[postString UTF8String] length:postString.length]];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        
        if ( connection ) {
            connectionData = [[NSMutableData alloc] init];
        }
        
        NSLog(@"username:%@, password:%@",username,password);
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
    NSLog(@"%@", [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding]);
    connectionData = nil;
    // proceed with application based on whether authentication worked or not.
}
@end
