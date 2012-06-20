//
//  Business.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Business : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *business_id;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;

-(id) initWithName:(NSString *)name type:(NSString *)type business_id:(NSString *)business_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude;
@end
