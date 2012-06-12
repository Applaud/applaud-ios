//
//  BusinessAnnotation.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "BusinessAnnotation.h"

@implementation BusinessAnnotation
@synthesize business = _business;
@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (id) initWithBusiness:(Business *)b {
    if(self = [super init]) {
        self.business = b;
        self.title = self.business.name;
        self.subtitle = self.business.type;
        _coordinate = CLLocationCoordinate2DMake(self.business.latitude.floatValue,
                                                     self.business.longitude.floatValue);
    }
    return self;
}

@end
