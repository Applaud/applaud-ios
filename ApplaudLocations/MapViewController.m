//
//  MapViewController.m
//  ApplaudLocations
//
//  Created by Luke Lovett on 6/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "MapViewController.h"
#import "Business.h"
#import "BusinessAnnotation.h"

@implementation MapViewController

@synthesize mapView;
@synthesize businesses = _businesses;

#pragma mark -
#pragma mark View Load/Unload

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mapView = [[MKMapView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
        mapView.userTrackingMode = MKUserTrackingModeNone;
        mapView.centerCoordinate = CLLocationCoordinate2DMake(LATITUDE, LONGITUDE);

        self.view = mapView;
       
        // Register as an observer to the BusinessLocationsTracker
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationUpdate:)
                                                     name:@"LOCATION_CHANGE"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationUpdate:)
                                                     name:@"BUSINESS_RECIEVED"
                                                   object:nil];
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    mapView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Map View Delegate Methods

/**
 * This gets called when the user's location changes. This is part of the
 * MKMapViewDelegate protocol.
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // Zoom to the location
    CLLocationCoordinate2D center = [userLocation coordinate];
    [self zoomMapTo:center];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applaud" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark Other Methods

- (void)notificationUpdate:(NSNotification *)notification {
    if([notification.name isEqualToString:@"LOCATION_CHANGE"]) {
        CLLocation *newLocation = notification.object;
        [self zoomMapTo:newLocation.coordinate];
    }
    else if([notification.name isEqualToString:@"BUSINESS_RECIEVED"]) {
        for(Business *b in notification.object) {
            BusinessAnnotation *busAnnotation = [[BusinessAnnotation alloc] initWithBusiness:b];
            [self.businesses addObject:busAnnotation];
            [self.mapView addAnnotation:busAnnotation];
        }
    }
}

/**
 * Zoom the map into a particular location.
 */
- (void)zoomMapTo:(CLLocationCoordinate2D)loc {
    
    // Zoom into the location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mapView centerCoordinate], BUSINESS_RADIUS_ENTRY,                                                                    BUSINESS_RADIUS_ENTRY);
    [mapView setRegion:region animated:YES];
}

@end
