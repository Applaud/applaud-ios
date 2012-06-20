//
//  FirstTimeNavigatorViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/18/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "FirstTimeNavigatorViewController.h"

@implementation FirstTimeNavigatorViewController

@synthesize tabBarController;
@synthesize window = _window;

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
    [tabBarController setSelectedIndex:0];
    _window.rootViewController = tabBarController;
}

- (IBAction)questionsView:(id)sender {
    [tabBarController setSelectedIndex:3];
    _window.rootViewController = tabBarController;
}

- (IBAction)feedbackView:(id)sender {
    [tabBarController setSelectedIndex:2];
    _window.rootViewController = tabBarController;
}

- (IBAction)newsfeedView:(id)sender {
    [tabBarController setSelectedIndex:4];
    _window.rootViewController = tabBarController;
}

@end