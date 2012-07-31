//
//  Employee.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Employee.h"

@implementation Employee

-(id)initWithFirstName:(NSString *)name
              lastName:(NSString *)lastname
                   bio:(NSString *)bio
              imageURL:(NSURL *)imageURL
            profileTitle:(NSString *)profileTitle
            dimensions:(NSArray *)dims
           employee_id:(int) employee_id {
    if(self = [super init]) {
        _firstName = name;
        _lastName = lastname;
        _bio = bio;
        _imageURL = imageURL;
        _ratingProfileTitle = profileTitle;
        _ratingDimensions = dims;
        _employee_id = employee_id;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
