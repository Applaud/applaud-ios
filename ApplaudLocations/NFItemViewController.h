//
//  NFItemViewController.h
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFItem.h"
#import "UIImage+Scale.h"

#define VIEW_PADDING 10.0f
#define IMAGE_SIZE 130.0f
#define ELEMENT_PADDING 10.0f
#define NAVIGATION_GAP 42.0f    // Gap left for the navigationBar of the UINavigationController

@interface NFItemViewController : UIViewController
@property (nonatomic, strong) NFItem *item;
@property IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyText;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@end
