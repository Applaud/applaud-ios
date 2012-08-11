//
//  Comment.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(id)initWithText:(NSString *)text photo_id:(int)photo_id user_id:(int)user_id
             date:(NSDate *)date_created comment_id:(int)comment_id
        firstName:(NSString *)firstName lastName:(NSString *)lastName {
    if(self = [super init]) {
        _text = text;
        _photo_id = photo_id;
        _user_id = user_id;
        _date_created = date_created;
        _comment_id = comment_id;
        _firstName = firstName;
        _lastName = lastName;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@ (%@)",
            self.text.length < 50 ? self.text : [self.text substringToIndex:50],
            self.firstName,
            self.lastName,
            [self.date_created description]];
}

@end
