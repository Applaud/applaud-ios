//
//  Survey.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Survey.h"

@implementation Survey
@synthesize title = _title;
@synthesize summary = _summary;
@synthesize fields = _fields;
@synthesize answers = _answers;

-(id) initWithTitle:(NSString *)title summary:(NSString *)summary fields:(NSMutableArray *)fields {
    if(self = [super init]) {
        _title = title;
        _summary = summary;
        _fields = fields;
        _answers = [[NSMutableArray alloc] initWithCapacity:fields.count];
        int i;
        for(i = 0; i < _fields.count; i++) {
            [_answers addObject:[[NSNull alloc] init]];
        }
    }
    return self;
}
@end
