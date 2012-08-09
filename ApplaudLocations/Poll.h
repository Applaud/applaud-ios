//
//  Poll.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Poll : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, strong) NSMutableArray *responses;
@property (nonatomic) int poll_id;
@property (nonatomic, strong) NSDate *date_created;
@property (nonatomic) BOOL show_results;
@property (nonatomic) int user_rating;
@property (nonatomic, readonly) int total_votes;
@property (nonatomic) int my_user_rating;
@property (nonatomic) BOOL can_rate;

-(id)initWithTitle:(NSString*)title
           options:(NSMutableArray*)options
         responses:(NSMutableArray*)responses
      date_created:(NSDate*)date_created
       user_rating:(int)user_rating
      show_results:(BOOL)show_results
          can_rate:(BOOL)can_rate
           poll_id:(int)poll_id;

@end
