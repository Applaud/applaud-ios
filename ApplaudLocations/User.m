//
//  User.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithName:(NSString*)name username:(NSString*)username {
    self = [super init];
    if ( self ) {
        _name = name;
        _username = username;
    }
    return self;
}

- (NSString*)description {
    return self.username;
}

@end
