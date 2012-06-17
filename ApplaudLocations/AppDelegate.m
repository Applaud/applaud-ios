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
    EmployeeListViewController *elvc = [[EmployeeListViewController alloc] init];
    [elvc setTitle:@"Employees"];
    UINavigationController *employeeNav = [[UINavigationController alloc] initWithRootViewController:elvc];
    elvc.navigationController = employeeNav;
    tabNavigator.viewControllers = [NSArray arrayWithObjects:
                                    employeeNav,
                                    [[UIViewController alloc] init],    // This is a dummy!!
                                    [[QuestionsViewController alloc] init],
                                    [[NFViewController alloc] init],
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

/*
 * make sure we can't select the empty view controller in the space between evaluations and everything else
 */
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if([viewController isEqual:[tabBarController.viewControllers objectAtIndex:1]])
        return NO;
    return YES;

}
@end
