//
//  Employee.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Employee.h"

@implementation Employee
@synthesize name = _name;
@synthesize bio = _bio;
@synthesize image = _image;

-(id)initWithName:(NSString *)name bio:(NSString *)bio image:(UIImage *)image {
    if(self = [super init]) {
        _name = name;
        _bio = bio;
        _image = image;
    }
    return self;
}
@end
