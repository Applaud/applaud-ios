//
//  ThreadPost.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ThreadPost : NSObject

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSDate *date_created;
@property (nonatomic, strong) User *user;
@property (nonatomic) int upvotes;
@property (nonatomic) int downvotes;
@property (nonatomic) int threadpost_id;
@property (nonatomic) int my_rating;

- (id)initWithBody:(NSString*)body
      date_created:(NSDate*)date
           upvotes:(int)upvotes
         downvotes:(int)downvotes
     threadpost_id:(int)myid;

@end
