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
}
@property (strong, nonatomic) CLLocationManager *locMan;  // The location manager

- (void)findBusinessesWithLocation:(CLLocationCoordinate2D)location;
- (void)startUpdatingLocation;

extern int error_code;

@end
