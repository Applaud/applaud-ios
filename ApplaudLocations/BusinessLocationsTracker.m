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
    NSLog(@"Error finding location: %@",error);
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
        // put some info in the notificationcenter
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BUSINESS_RECEIVED" object:businessArray];
    };
    NSDictionary *getDict = @{ @"latitude" : @(location.latitude),
                               @"longitude" : @(location.longitude) };
    [ConnectionManager serverRequest:@"GET" withParams:getDict url:WHEREAMI_URL callback:callback];
}

@end
