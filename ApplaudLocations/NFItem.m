//
//  NFItem.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/14/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFItem.h"

/*
 * A news feed item -- this corresponds to the Django model.
 */

@implementation NFItem
@synthesize body = _body;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize date = _date;
@synthesize image = _image;

-(id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle body:(NSString *)body date:(NSDate *)date image:(UIImage *)image {
    if(self = [super init]) {
        _title = title;
        _subtitle = subtitle;
        _body = body;
        _date = date;
        _image = image;
    }
    return self;
}
@end
