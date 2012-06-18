//
//  AppDelegate.h
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/8/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BusinessLocationsTracker.h"
#import "GeneralFeedbackViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, NSURLConnectionDelegate> {
    NSMutableData *connectionData;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BusinessLocationsTracker *tracker;


/**
 * This stuff is for CoreData
 */
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentPath;


- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;

@end
