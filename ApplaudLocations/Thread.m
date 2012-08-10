//
//  Thread.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Thread.h"

@implementation Thread

- (id)initWithTitle:(NSString*)title
       date_created:(NSDate*)date_created
            upvotes:(int)upvotes
          downvotes:(int)downvotes
              posts:(NSMutableArray*)posts
          thread_id:(int)myid {
    self = [super init];
    if ( self ) {
        _title = title;
        _date_created = date_created;
        _upvotes = upvotes;
        _downvotes = downvotes;
        _threadPosts = posts;
        _thread_id = myid;
    }
    return self;
}

- (NSString*)description {
    return self.title;
}

@end
