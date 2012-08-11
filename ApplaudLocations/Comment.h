//
//  Comment.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject
@property (nonatomic) int user_id;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSDate *date_created;
@property (nonatomic) int photo_id;
@property (nonatomic) int comment_id;

-(id)initWithText:(NSString *)text photo_id:(int)photo_id user_id:(int)user_id
             date:(NSDate *)date_created comment_id:(int)comment_id
        firstName:(NSString *)firstName lastName:(NSString *)lastName;
@end
