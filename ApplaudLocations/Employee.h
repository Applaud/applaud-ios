//
//  Employee.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/15/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Employee : NSObject
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray *ratingDimensions;    // What dimensions the employee can be rated on
@property (nonatomic) int employee_id;

- (id) initWithFirstName:(NSString *)firstname lastName:(NSString *)lastname bio:(NSString *)bio image:(UIImage *)image dimensions:(NSArray *)dims employee_id:(int) employee_id;

@end
