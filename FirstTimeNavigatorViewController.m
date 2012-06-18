//
//  FirstTimeNavigatorViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/18/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "FirstTimeNavigatorViewController.h"

@interface FirstTimeNavigatorViewController ()

@end

@implementation FirstTimeNavigatorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
