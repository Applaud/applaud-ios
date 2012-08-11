//
//  User.h
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIImage *profilePicture;

- (id)initWithName:(NSString*)name username:(NSString*)username;

@end
