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
@synthesize goog_id = _goog_id;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

-(id) initWithName:(NSString *)name type:(NSString *)type goog_id:(NSString *)goog_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude {
  if(self = [super init]) {
    self.name = name;
    self.type = type;
    self.goog_id = goog_id;
    self.latitude = latitude;
    self.longitude = longitude;
  }
  return self;
}

@end
