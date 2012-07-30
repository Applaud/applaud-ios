//
//  Survey.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Survey.h"

@implementation Survey

-(id) initWithTitle:(NSString *)title summary:(NSString *)summary business_id:(int)business_id fields:(NSMutableArray *)fields {
    if(self = [super init]) {
        _title = title;
        _summary = summary;
        _fields = fields;
        _answers = [[NSMutableArray alloc] initWithCapacity:fields.count];
        _business_id = business_id;
        int i;
        for(i = 0; i < _fields.count; i++) {
            [_answers addObject:[[NSNull alloc] init]];
        }
    }
    return self;
}
@end
