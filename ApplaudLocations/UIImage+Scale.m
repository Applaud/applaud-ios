//
//  UIImage+Scale.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/3/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

/*
 * Stolen from a blog again! Thanks!
 */
#import "UIImage+Scale.h"

@implementation UIImage (Scale)

-(UIImage *)scaleToSize:(float)longestSide {
    float ratio = 1.0;
    if(self.size.width > self.size.height) {
        if(self.size.width > longestSide) {
            ratio = longestSide * 1.0/self.size.width;
        }
    }
    else if(self.size.height > self.size.width) {
        ratio = longestSide * 1.0/self.size.height;
    }
    UIGraphicsBeginImageContext(CGSizeMake(longestSide, longestSide));
    [self drawInRect:CGRectMake(0, 0, self.size.width*ratio, self.size.height*ratio)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
