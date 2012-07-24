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
@property (nonatomic) int business_id;
@property (nonatomic, copy) NSString *goog_id;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic, strong) NSDictionary *types;

-(id) initWithName:(NSString *)name goog_id:(NSString *)goog_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude
      primaryColor:(NSString *)primaryColor secondaryColor:(NSString *)secondaryColor types:(NSDictionary *) types;

-(id) initWithName:(NSString *)name type:(NSString *)type business_id:(int)bus_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude;
@end
