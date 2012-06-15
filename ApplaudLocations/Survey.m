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

-(id) initWithTitle:(NSString *)title summary:(NSString *)summary fields:(NSMutableArray *)fields {
    if(self = [super init]) {
        _title = title;
        _summary = summary;
        _fields = fields;
    }
    return self;
}
@end
