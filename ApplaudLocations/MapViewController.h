//
//  MapViewController.h
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define LATITUDE 39.98184
#define LONGITUDE -83.004498

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    // This stores the location of the business we're at
    CLLocationCoordinate2D businessLocation;
}

@property (nonatomic, strong) MKMapView *mapView;

- (void)zoomMapTo:(CLLocationCoordinate2D)loc;

@end
