//
//  Poll.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Poll.h"

@implementation Poll

-(id)initWithTitle:(NSString*)title
           options:(NSMutableArray*)options
         responses:(NSMutableArray*)responses
           poll_id:(int)poll_id {
    self = [super init];
    if ( self ) {
        _title = title;
        _options = options;
        _responses = responses;
        _poll_id = poll_id;
    }
    return self;
}

-(NSString*)description {
    return self.title;
}

@end
