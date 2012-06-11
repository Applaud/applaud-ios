//
//  BusinessLocations.h
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/10/12.
//  Copyright (c) 2012 Oberlin College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BusinessLocationsTracker : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locMan;
}

@end
