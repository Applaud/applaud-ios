//
//  Business.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Business : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *goog_id;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

-(id) initWithName:(NSString *)name type:(NSString *)type goog_id:(NSString *)goog_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude;
@end
