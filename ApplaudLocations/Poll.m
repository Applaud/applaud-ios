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
      show_results:(BOOL)show_results
           poll_id:(int)poll_id {
    self = [super init];
    if ( self ) {
        _title = title;
        _options = options;
        self.responses = responses;
        _show_results = show_results;
        _poll_id = poll_id;
    }
    return self;
}

- (void)setResponses:(NSMutableArray *)responses {
    _total_votes = 0;
    for ( NSDictionary *dict in responses ) {
        _total_votes += [dict[@"count"] intValue];
    }
    _responses = responses;
}

-(NSString*)description {
    return self.title;
}

@end
