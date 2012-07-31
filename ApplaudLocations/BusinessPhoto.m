//
//  BusinessPhoto.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/25/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "BusinessPhoto.h"

@implementation BusinessPhoto

-(id)initWithImage:(UIImage *)image tags:(NSArray *)tags
           upvotes:(int)upvotes downvotes:(int)downvotes
          business:(int)business uploaded_by:(NSDictionary *)uploaded_by
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
