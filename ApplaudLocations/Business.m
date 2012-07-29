//
//  Business.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/12/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "Business.h"

@implementation Business
@synthesize name = _name;
@synthesize business_id = _business_id;
@synthesize goog_id = _goog_id;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize primaryColor = _primaryColor;
@synthesize secondaryColor = _secondaryColor;
@synthesize types = _types;

- (id)initWithName:(NSString *)name goog_id:(NSString *)goog_id
          latitude:(NSNumber *) latitude longitude:(NSNumber *) longitude
        primaryColor:(NSString *)primaryColor secondaryColor:(NSString *)secondaryColor
        types: (NSDictionary *)types {
    if(self = [super init]) {
        _name = name;
        _goog_id = goog_id;
        _latitude = latitude;
        _longitude = longitude;
        _primaryColor = [self colorWithHex:primaryColor];
        _secondaryColor = [self colorWithHex:secondaryColor];
        _types = types;
    }
    return self;
}


/*
 * Convert a hex string to a UIColor *. The string should be in the format
 * "#[0-9a-f]{6}".
 */
- (UIColor *)colorWithHex:(NSString *)hexString {
    if(!hexString){
        return nil;
    }
    
    NSString *red = [hexString substringWithRange:NSMakeRange(1, 2)];
    NSString *green = [hexString substringWithRange:NSMakeRange(3, 2)];
    NSString *blue = [hexString substringWithRange:NSMakeRange(5, 2)];
    unsigned int redVal;
    unsigned int greenVal;
    unsigned int blueVal;
    [[NSScanner scannerWithString:red] scanHexInt:&redVal];
    [[NSScanner scannerWithString:green] scanHexInt:&greenVal];
    [[NSScanner scannerWithString:blue] scanHexInt:&blueVal];
    return [[UIColor alloc] initWithRed:redVal/255.0f
                                  green:greenVal/255.0f
                                   blue:blueVal/255.0f
                                  alpha:1.0f];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%d/%@) [%@, %@]", self.name, self.business_id, self.goog_id, self.primaryColor, self.secondaryColor];
}

@end
