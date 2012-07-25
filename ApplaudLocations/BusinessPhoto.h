//
//  BusinessPhoto.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/25/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessPhoto : NSObject
// All these names line up with the Django model.
// The only difference is that business and profile
// are stored as database IDs instead of foreign keys.
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSArray *tags;
@property (nonatomic) int upvotes;
@property (nonatomic) int downvotes;
@property (nonatomic) int business;
@property (nonatomic) int uploaded_by;
@property (nonatomic) BOOL active;

-(id)initWithImage:(UIImage *)image tags:(NSArray *)tags
           upvotes:(int)upvotes downvotes:(int)downvotes
          business:(int)business uploaded_by:(int)uploaded_by
            active:(BOOL)active;
@end
