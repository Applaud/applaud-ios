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
@synthesize scrollView = _scrollView;
@synthesize image;
@synthesize nameLabel;
@synthesize bioField;


- (id)initWithEmployee:(Employee *)e {
    if ( self = [super init] ) {
        _employee = e;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.nameLabel setText:[NSString stringWithFormat:@"%@ %@",
                             self.employee.firstName, self.employee.lastName]];

    if ( self.employee.bio != (id)[NSNull null] && self.employee.bio.length > 0 ) {
        [self.bioField setText:self.employee.bio];
    }
    else {
        NSLog(@"Null bio for %@.",self.employee);
    }
    
    // Keeps track of where we're putting labels/sliders
    int curr_y = RATING_FIELDS_BEGIN;
    
    // Parse all of the rating dimensions
    for ( NSString *dimension in self.employee.ratingDimensions ) {
        // Create a label
        UILabel *dimensionLabel = [[UILabel alloc] 
                                   initWithFrame:CGRectMake(0,
                                                            curr_y,
                                                            self.view.frame.size.width,
                                                            RATING_FIELD_HEIGHT/2)];
        [dimensionLabel setText:dimension];
        // Create a slider
        UISlider *dimensionSlider = [[UISlider alloc] 
                                     initWithFrame:CGRectMake(0, 
                                                              curr_y + 20,
                                                              self.view.frame.size.width,                                                                  RATING_FIELD_HEIGHT)];
        [dimensionSlider setMinimumValue:0.0f];
        [dimensionSlider setMaximumValue:1.0f];
        curr_y += RATING_FIELD_HEIGHT;
        [self.view addSubview:dimensionLabel];
        [self.view addSubview:dimensionSlider];
    }
    // Tell our scroll view how big its contents are, so we can scroll in it.
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             curr_y);
    

    
}

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setNameLabel:nil];
    [self setBioField:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
