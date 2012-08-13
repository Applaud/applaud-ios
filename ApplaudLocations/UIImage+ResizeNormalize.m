//
//  UIImage+ResizeNormalize.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "UIImage+ResizeNormalize.h"

@implementation UIImage (ResizeNormalize)

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

-(UIImage *)resizedImage{
    CGFloat height = self.size.height;
    CGFloat width = self.size.width;
    CGRect finalSize = CGRectZero;
    UIImage *resizedImage;
    if(height > width) {
        float scale = 480.0/height;
        NSLog(@"SCALE %f", scale);
        float newWidth = width*scale;
        float newHeight = 480.0;
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        finalSize = CGRectMake(0, 0, newWidth-1, newHeight-1);
    }
    else {
        float scale = 320.0/width;
        NSLog(@"SCALE %f", scale);
        finalSize = CGRectMake(0, (height*scale-320.0)/2, 320.0, 480.0);
        float newHeight = scale*height;
        float newWidth = 320.0;
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    NSLog(@"SIZES %f %f %f %f", finalSize.origin.x, finalSize.origin.y,
          finalSize.size.width, finalSize.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], finalSize);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    NSLog(@"FINAL SIZE %f %f", finalImage.size.width, finalImage.size.height);
    return finalImage;
}


@end
