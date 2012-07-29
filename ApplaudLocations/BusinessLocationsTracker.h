//
//  BusinessLocations.h
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/10/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BusinessLocationsTracker : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate> {
    CLLocationCoordinate2D lastCoordinate; // The last coordinate we were recorded in
    
    NSURLConnection *urlConnection; // Connection to our backend
    NSMutableData *serverData;   // Data received from the server
}
@property (strong, nonatomic) CLLocationManager *locMan;  // The location manager
// Convenient method to show an alert to the user with only an "OK" button
- (void)showAlertView:(NSString *)msg;

- (void)findBusinessesWithLocation:(CLLocationCoordinate2D)location;
- (void)startUpdatingLocation;

extern int error_code;

@end
