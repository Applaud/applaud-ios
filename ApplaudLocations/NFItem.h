//
//  NFItem.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/14/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFItem : NSObject
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *date; // should be changed to an NSDate when I figure out date parsing

-(id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle body:(NSString *)body date:(NSString *)date;

@end
