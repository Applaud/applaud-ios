//
//  BusinessLocations.h
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/10/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BusinessLocationsTracker : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locMan;  // The location manager
    CLLocationCoordinate2D lastCoordinate; // The last coordinate we were recorded in
    
    NSURLConnection *urlConnection; // Connection to our backend
    NSMutableData *serverData;   // Data received from the server
}

@end
