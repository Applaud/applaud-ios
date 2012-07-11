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
        NSLog(@"<----- OLD: %@     NEW:%@  ----->", newLocation, oldLocation);
        lastCoordinate = newLocation.coordinate;
        [self findBusinessesWithLocation:newLocation.coordinate];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOCATION_CHANGE" object:newLocation];
        NSLog(@"<----------> CHANGING LOCATION <---------->");
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
                                                   goog_id:[dict objectForKey:@"goog_id"]
                                                  latitude:[dict objectForKey:@"latitude"]
                                                 longitude:[dict objectForKey:@"longitude"]
                                              primaryColor:[dict objectForKey:@"primary"]
                                            secondaryColor:[dict objectForKey:@"secondary"]];
            bus.business_id = [[dict objectForKey:@"id"] intValue];
            NSLog(@"Got business: %@", bus.description);
            NSLog(@"%@", [dict objectForKey:@"primary"]);
            [businessArray addObject:bus];
        }
        NSLog(@"sent BUSINESS_RECEIVED");
        // put some info in the notificationcenter
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BUSINESS_RECEIVED" object:businessArray];
    };

/*    NSArray *keyArray = [[NSArray alloc] initWithObjects:@"latitude", @"longitude", nil];
    NSArray *valArray = [[NSArray alloc] initWithObjects:
                         [NSNumber numberWithFloat:location.latitude], 
                         [NSNumber numberWithFloat:location.longitude], nil];*/
//    NSDictionary *getDict = [[NSDictionary alloc] initWithObjects:valArray forKeys:keyArray];

    // dummy businesses for debugging
    [ConnectionManager serverRequest:@"GET" withParams:nil url:EXAMPLE_URL callback:callback];
/*    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@", SERVER_URL, EXAMPLE_URL];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSError *e;
    NSData *d = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&e];
    callback(d);*/
    // actual businesses
    //[ConnectionManager serverRequest:@"GET" withParams:getDict url:WHEREAMI_URL callback:callback];
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
