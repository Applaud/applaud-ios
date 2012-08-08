//
//  BusinessPhoto.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/25/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessPhoto : NSObject

@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSArray *tags;
@property (nonatomic) int upvotes;
@property (nonatomic) int downvotes;
@property (nonatomic) int business;
@property (nonatomic) NSDictionary *uploaded_by;
@property (nonatomic) BOOL active;
@property (nonatomic) int photo_id;

-(id)initWithImage:(NSURL *)imageURL tags:(NSArray *)tags
           upvotes:(int)upvotes downvotes:(int)downvotes
          business:(int)business uploaded_by:(NSDictionary *)uploaded_by
            active:(BOOL)active photo_id:(int)photo_id;
@end
