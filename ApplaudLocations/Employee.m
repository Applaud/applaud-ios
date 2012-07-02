//
//  Employee.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Employee.h"

@implementation Employee
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize bio = _bio;
@synthesize image = _image;
@synthesize ratingDimensions = _ratingDimensions;
@synthesize employee_id = _employee_id;

-(id)initWithFirstName:(NSString *)name lastName:(NSString *)lastname bio:(NSString *)bio image:(UIImage *)image dimensions:(NSArray *)dims employee_id:(int) employee_id {
    if(self = [super init]) {
        _firstName = name;
        _lastName = lastname;
        _bio = bio;
        _image = image;
        _ratingDimensions = dims;
        _employee_id = employee_id;
        _image = image;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
