//
//  Business.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Business.h"

@implementation Business
@synthesize name = _name;
@synthesize type = _type;
@synthesize business_id = _business_id;
@synthesize goog_id = _goog_id;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

- (id)initWithName:(NSString *)name type:(NSString *)type goog_id:(NSString *)goog_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude {
  if(self = [super init]) {
    _name = name;
    _type = type;
    _goog_id = goog_id;
      
    _latitude = latitude;
    _longitude = longitude;
  }
  return self;
}

- (id)initWithName:(NSString *)name type:(NSString *)type business_id:(int)bus_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude {
    if(self = [super init]) {
        _name = name;
        _type = type;
        _business_id = bus_id;
        _latitude = latitude;
        _longitude = longitude;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%d/%@)", self.name, self.business_id, self.goog_id];
}

@end
