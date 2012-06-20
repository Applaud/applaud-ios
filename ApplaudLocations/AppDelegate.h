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
#import "ApplaudProgramSettingsModel.h"
#import "FBConnect.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, NSURLConnectionDelegate, FBSessionDelegate> {
    NSMutableData *connectionData;
    Facebook *facebook;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BusinessLocationsTracker *tracker;
@property (nonatomic, retain) Facebook *facebook;

/**
 * Stores the user's settings
 */
@property (nonatomic, strong, readonly) ApplaudProgramSettingsModel *settings;


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
