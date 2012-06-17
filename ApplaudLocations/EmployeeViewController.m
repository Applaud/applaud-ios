//
//  EmployeeViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "EmployeeViewController.h"
#import "Employee.h"

@interface EmployeeViewController ()

@end

@implementation EmployeeViewController
@synthesize employee = _employee;
@synthesize image;
@synthesize nameLabel;
@synthesize bioField;


- (id)initWithEmployee:(Employee *)e {
    if ( self = [super init] ) {
        employee = e;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(nil == _employee) {
        [self.nameLabel setText:[NSString stringWithFormat:@"%@ %@",
                                 employee.firstName, employee.lastName]];
        [self.bioField setText:employee.bio];
    }
}

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setNameLabel:nil];
    [self setBioField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
