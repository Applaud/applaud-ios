//
//  ThreadPost.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ThreadPost.h"

@implementation ThreadPost

- (id)initWithBody:(NSString*)body
      date_created:(NSDate*)date
           upvotes:(int)upvotes
         downvotes:(int)downvotes
     threadpost_id:(int)myid {
    self = [super init];
    if ( self ) {
        _date_created = date;
        _body = body;
        _downvotes = downvotes;
        _upvotes = upvotes;
        _threadpost_id = myid;
    }
    return self;
}

- (NSString*)description {
    return self.body;
}

@end
