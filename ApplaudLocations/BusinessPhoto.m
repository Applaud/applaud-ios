//
//  BusinessPhoto.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/25/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "BusinessPhoto.h"

@implementation BusinessPhoto

-(id)initWithImage:(NSURL *)imageURL tags:(NSArray *)tags
           upvotes:(int)upvotes downvotes:(int)downvotes
          business:(int)business uploaded_by:(NSDictionary *)uploaded_by
            active:(BOOL)active photo_id:(int)photo_id {
    if(self = [super init]) {
        _imageURL = imageURL;
        _tags = tags;
        _upvotes = upvotes;
        _downvotes = downvotes;
        _business = business;
        _uploaded_by = uploaded_by;
        _active = active;
        _photo_id = photo_id;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"url: %@, business: %d, active: %@",
            self.imageURL, self.business, self.active ? @"true" : @"false"];
}
@end
