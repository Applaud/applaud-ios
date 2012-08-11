//
//  Thread.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Thread : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *date_created;
@property (nonatomic, strong) User *user_creator;
@property (nonatomic, strong) NSMutableArray *threadPosts;
@property (nonatomic) int upvotes;
@property (nonatomic) int downvotes;
@property (nonatomic) int thread_id;
@property (nonatomic) int my_rating;

- (id)initWithTitle:(NSString*)title
date_created:(NSDate*)date_create
upvotes:(int)upvotes
downvotes:(int)downvotes
posts:(NSArray*)posts
thread_id:(int)id;

@end
