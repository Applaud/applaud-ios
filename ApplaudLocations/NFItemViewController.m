//
//  NFItemViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFItemViewController.h"

@interface NFItemViewController ()

@end

@implementation NFItemViewController

@synthesize item = _item;
@synthesize titleLabel = _titleLabel;
@synthesize bodyText = _bodyText;
@synthesize subtitleLabel = _subtitleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setItem:(NFItem *)item {
    _item = item;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = self.item.title;
    self.bodyText.text = self.item.body;
    self.subtitleLabel.text = self.item.subtitle;
}

- (void)viewDidUnload
{
    [self setBodyText:nil];
    [self setSubtitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
