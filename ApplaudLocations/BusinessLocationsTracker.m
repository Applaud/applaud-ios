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
        self.locMan = [[CLLocationManager alloc] init];
        self.locMan.desiredAccuracy = kCLLocationAccuracyBest;
        self.locMan.delegate = self;
        serverData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)startUpdatingLocation {
    [self.locMan startUpdatingLocation];
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
    }
    
    [self.locMan stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    UIAlertView *connection_problem = [[UIAlertView alloc] initWithTitle:@"Connection error"
//                                                                 message:@"Couldn't get business data"
//                                                                delegate:nil
//                                                       cancelButtonTitle:nil
//                                                       otherButtonTitles:@"OK", nil];
//    [connection_problem show];
//    NSLog(@"Error finding location: %@",error);
}

#pragma mark -
#pragma mark Call to Backend

/**
 * What we do when we want to find businesses around a certain location.
 */
- (void)findBusinessesWithLocation:(CLLocationCoordinate2D)location {
    void (^callback)(NSHTTPURLResponse *, NSData *) = ^(NSHTTPURLResponse *r, NSData *dat){
        if ( error_code )
            return;

        NSError *e;
        NSMutableDictionary *businesses = [NSJSONSerialization JSONObjectWithData:dat options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:&e];
        NSMutableArray *businessArray = [[NSMutableArray alloc] init];
        for(NSDictionary *dict in businesses[@"nearby_businesses"]) {
            Business *bus = [[Business alloc] initWithName:dict[@"name"]
                                                   goog_id:dict[@"goog_id"]
                                                  latitude:dict[@"latitude"]
                                                 longitude:dict[@"longitude"]
                                              primaryColor:nil
                                            secondaryColor:nil
                                                     types:dict[@"types"]];
            bus.business_id = [dict[@"business_id"] intValue];
            [businessArray addObject:bus];
        }
        
        if( ! businessArray.count ){
            [[[UIAlertView alloc] initWithTitle:@"Sorry..."
                                        message:@"There aren't any businesses in your area"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Refresh", nil] show];
        }
        // put some info in the notificationcenter
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BUSINESS_RECEIVED" object:businessArray];
    };
    NSDictionary *getDict = @{ @"latitude" : @(location.latitude),
                               @"longitude" : @(location.longitude) };
    [ConnectionManager serverRequest:@"GET" withParams:getDict url:WHEREAMI_URL callback:callback];
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
#pragma UIAlertViewDelegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        exit(0);
    }
    else if(buttonIndex == 1) {
        [self findBusinessesWithLocation:self.locMan.location.coordinate];
    }
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
