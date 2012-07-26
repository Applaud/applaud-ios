//
//  BusinessPhoto.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/25/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "BusinessPhoto.h"

@implementation BusinessPhoto
//@synthesize image = _image;
//@synthesize tags = _tags;
//@synthesize upvotes = _upvotes;
//@synthesize downvotes = _downvotes;
//@synthesize business = _business;
//@synthesize uploaded_by = _uploaded_by;
//@synthesize active = _active;

-(id)initWithImage:(UIImage *)image tags:(NSArray *)tags
           upvotes:(int)upvotes downvotes:(int)downvotes
          business:(int)business uploaded_by:(int)uploaded_by
            active:(BOOL)active {
    if(self = [super init]) {
        _image = image;
        _tags = tags;
        _upvotes = upvotes;
        _downvotes = downvotes;
        _business = business;
        _uploaded_by = uploaded_by;
        _active = active;
    }
    return self;
}
@end
