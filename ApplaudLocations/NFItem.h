//
//  NFItem.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/14/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFItem : NSObject
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSURL *imageURL;

-(id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle body:(NSString *)body date:(NSDate *)date imageURL:(NSURL *)imageURL;

@end
