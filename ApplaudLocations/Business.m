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
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

-(id) initWithName:(NSString *)name type:(NSString *)type business_id:(int)business_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude {
  if(self = [super init]) {
    self.name = name;
    self.type = type;
    self.business_id = business_id;
    self.latitude = latitude;
    self.longitude = longitude;
  }
  return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%d)", self.name, self.business_id];
}

@end
