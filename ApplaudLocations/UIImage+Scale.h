//
//  UIImage+Scale.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/3/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)
-(UIImage *)scaleToSize:(float)longestSide;
@end
