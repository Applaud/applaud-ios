//
//  BusinessLocations.m
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/10/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "BusinessLocationsTracker.h"
#import "Business.h"
#import "ConnectionManager.h"

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
        // We left the business, or are starting up
        lastCoordinate = newLocation.coordinate;
        [self findBusinessesWithLocation:newLocation.coordinate];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOCATION_CHANGE" object:newLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *connection_problem = [[UIAlertView alloc] initWithTitle:@"Connection error"
                                                                 message:@"Couldn't get business data"
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"OK", nil];
    [connection_problem show];
    NSLog(@"Error finding location: %@",error);
}

#pragma mark -
#pragma mark Call to Backend

/**
 * What we do when we want to find businesses around a certain location.
 */
- (void)findBusinessesWithLocation:(CLLocationCoordinate2D)location {
    void (^callback)(NSData *) = ^(NSData *dat){
        NSError *e;
        NSMutableDictionary *businesses = [NSJSONSerialization JSONObjectWithData:dat options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:&e];
        NSMutableArray *businessArray = [[NSMutableArray alloc] init];
        for(NSDictionary *dict in [businesses objectForKey:@"nearby_businesses"]) {
            Business *bus = [[Business alloc] initWithName:[dict objectForKey:@"name"]
                                                      type:[dict objectForKey:@"type"]
                                                   business_id:[[dict objectForKey:@"id"] floatValue]
                                                  latitude:[dict objectForKey:@"latitude"]
                                                 longitude:[dict objectForKey:@"longitude"]];
            [businessArray addObject:bus];
        }
        
        // put some info in the notificationcenter
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BUSINESS_RECEIVED" object:businessArray]; 
    };

//    NSArray *keyArray = [[NSArray alloc] initWithObjects:@"latitude", @"longitude", nil];
//    NSArray *valArray = [[NSArray alloc] initWithObjects:
//                         [NSNumber numberWithFloat:location.latitude], 
//                         [NSNumber numberWithFloat:location.longitude], nil];
//    NSDictionary *getDict = [[NSDictionary alloc] initWithObjects:valArray forKeys:keyArray];

    // dummy businesses for debugging
    [ConnectionManager serverRequest:@"GET" withParams:nil url:@"/example3/" callback:callback];
    
    // actual businesses
    //[ConnectionManager serverRequest:@"GET" withParams:getDict url:@"/checkin" callback:callback];
}

/**
 * Got a chunk of data from the server.
 */
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [serverData appendData:data];
}

/**
 * Could not connect to the server.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self showAlertView:[NSString stringWithFormat:@"Connection error: %@",error]];
    
    serverData = nil;
    urlConnection = nil;
}

#pragma mark -
#pragma mark Other Methods

/**
 * Convenient way to display a alert to the user with only an 'OK' button.
 */
- (void)showAlertView:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applaud" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
