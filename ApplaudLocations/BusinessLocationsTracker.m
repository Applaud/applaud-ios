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
//    NSArray *keyArray = [[NSArray alloc] initWithObjects:@"latitude", @"longitude", nil];
//    NSArray *valArray = [[NSArray alloc] initWithObjects:
//                         [NSNumber numberWithFloat:location.latitude], 
//                         [NSNumber numberWithFloat:location.longitude], nil];
//    NSDictionary *getDict = [[NSDictionary alloc] initWithObjects:valArray forKeys:keyArray];
//    NSString *urlString = [NSString stringWithFormat:
//                           @"http://ec2-107-22-6-55.compute-1.amazonaws.com/checkin%@",
//                           @"http://127.0.0.1:8000/checkin%@",
//                           [ConnectionManager GETStringFromDict:getDict]];

//    NSURL *url = [NSURL URLWithString:urlString];

    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, @"/example3"];
    NSURL *url = [NSURL URLWithString:urlString];

//    NSLog(@"Making request with URL: %@",[url description]);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    urlConnection = [[NSURLConnection alloc] initWithRequest:request 
                                                    delegate:self 
                                            startImmediately:YES];
}

/**
 * Got a chunk of data from the server.
 */
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [serverData appendData:data];
}

/**
 * Done getting info from the server.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *e = [[NSError alloc] init];
    NSMutableDictionary *businesses = [NSJSONSerialization JSONObjectWithData:serverData options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:&e];
    NSMutableArray *businessArray = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in [businesses objectForKey:@"nearby_businesses"]) {
        Business *bus = [[Business alloc] initWithName:[dict objectForKey:@"name"]
                                                  type:[dict objectForKey:@"type"]
                                               goog_id:[dict objectForKey:@"goog_id"]
                                              latitude:[dict objectForKey:@"latitude"]
                                             longitude:[dict objectForKey:@"longitude"]];
        [businessArray addObject:bus];
    }
    
    // put some info in the notificationcenter
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BUSINESS_RECEIVED" object:businessArray];
    businesses = nil;
    serverData = nil;
    urlConnection = nil;
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

/*
 * Sends a GET to the server and grabs a CSRF token. I really hope this works.
 */
+ (NSString *)getCSRFTokenFromURL:(NSString *)urlString {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSError *regexerr= nil;
//    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"value='(.*)'"
//                                                                      options:0
//                                                                        error:&regexerr];
//    NSTextCheckingResult *match = [regex firstMatchInString:html
//                                                    options:0
//                                                      range:NSMakeRange(0, [html length])];
//    return [html substringWithRange:[match rangeAtIndex:1]];
    return html;
}

@end
