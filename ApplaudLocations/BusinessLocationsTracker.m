//
//  BusinessLocations.m
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/10/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "BusinessLocationsTracker.h"

@implementation BusinessLocationsTracker

- (id)init {
    self = [super init];
    if ( self ) {
        locMan = [[CLLocationManager alloc] init];
        locMan.desiredAccuracy = kCLLocationAccuracyBest;
        locMan.delegate = self;
        [locMan startUpdatingLocation];
        serverData = [[NSMutableData alloc] init];
    }
    
    return self;
}

/**
 * This gets called whenever we get an updated location reading.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    
    // Ignore cached data
    if (t < -180)
        return;
        
    // Check distance
    if ( [[[CLLocation alloc] initWithLatitude:lastCoordinate.latitude longitude:lastCoordinate.longitude] distanceFromLocation:newLocation] > BUSINESS_RADIUS_EXIT) {
        // We left the business
        lastCoordinate = newLocation.coordinate;
        [self findBusinesses];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOCATION_CHANGE" object:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error finding location: %@",error);
}

#pragma mark -
#pragma mark Call to Backend

- (void)findBusinesses {
    NSURL *url = [NSURL URLWithString:
                  @"http://ec2-107-22-6-55.compute-1.amazonaws.com/example3"];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    urlConnection = [[NSURLConnection alloc] initWithRequest:request 
                                                    delegate:self 
                                            startImmediately:YES];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [serverData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"%@", [[NSString alloc] initWithData:serverData encoding:NSUTF8StringEncoding]);
    
    serverData = nil;
    urlConnection = nil;
    
    // put some info in the notificationcenter
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error: %@",error);
    
    serverData = nil;
    urlConnection = nil;
}

@end
