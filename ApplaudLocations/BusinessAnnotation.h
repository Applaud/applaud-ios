//
//  BusinessAnnotation.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Business.h"

@interface BusinessAnnotation : NSObject <MKAnnotation>
@property (nonatomic, strong) Business *business;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id) initWithBusiness:(Business *)b;
@end
