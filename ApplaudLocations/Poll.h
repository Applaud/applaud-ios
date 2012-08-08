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
@property (nonatomic) BOOL show_results;
@property (nonatomic, readonly) int total_votes;

-(id)initWithTitle:(NSString*)title
           options:(NSMutableArray*)options
         responses:(NSMutableArray*)responses
      show_results:(BOOL)show_results
           poll_id:(int)poll_id;

@end
