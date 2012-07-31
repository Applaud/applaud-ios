//
//  FirstTimeNavigatorViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/18/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "FirstTimeNavigatorViewController.h"

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

- (IBAction)employeeView:(id)sender {
    [self.tabBarController setSelectedIndex:2];
    _window.rootViewController = self.tabBarController;
}

- (IBAction)questionsView:(id)sender {
    [self.tabBarController setSelectedIndex:1];
    _window.rootViewController = self.tabBarController;
}

- (IBAction)newsfeedView:(id)sender {
    [self.tabBarController setSelectedIndex:0];
    _window.rootViewController = self.tabBarController;
}

@end
