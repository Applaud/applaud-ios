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
@synthesize submitButton;
@synthesize employee = _employee;
@synthesize scrollView = _scrollView;
@synthesize image;
@synthesize nameLabel;
@synthesize bioLabel;
@synthesize bioField;
@synthesize ratingDimensions = _ratingDimensions;


- (id)initWithEmployee:(Employee *)e {
    if ( self = [super init] ) {
        _employee = e;
        _ratingDimensions = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.nameLabel setText:[NSString stringWithFormat:@"%@ %@",
                             self.employee.firstName, self.employee.lastName]];

    // The y-coordinate of the first rating field
    int dimensionStart = RATING_FIELDS_BEGIN;
    if ( self.employee.bio != (id)[NSNull null] && self.employee.bio.length > 0 ) {
        [self.bioField setText:self.employee.bio];
    }
    else {
        int spaceGained = bioField.bounds.size.height + bioLabel.bounds.size.height;
        [self.bioField removeFromSuperview];
        [self.bioLabel removeFromSuperview];
        dimensionStart -= spaceGained;
    }
    
    // Keeps track of where we're putting labels/sliders
    int curr_y = dimensionStart;
    // i will be used as a tag for UISliders, so we can identify which one is which later.
    int i = 0;
    // Parse all of the rating dimensions
    for ( NSString *dimension in self.employee.ratingDimensions ) {
        // Create a label
        UILabel *dimensionLabel = [[UILabel alloc] 
                                   initWithFrame:CGRectMake(RATING_FIELD_SPACING,
                                                            curr_y,
                                                            self.view.frame.size.width-(2*RATING_FIELD_SPACING),
                                                            RATING_FIELD_HEIGHT/2)];
        [dimensionLabel setText:dimension];
        // Create a slider
        UISlider *dimensionSlider = [[UISlider alloc] 
                                     initWithFrame:CGRectMake(RATING_FIELD_SPACING, 
                                                              curr_y + 20,
                                                              self.view.frame.size.width-(2*RATING_FIELD_SPACING),                                                                  RATING_FIELD_HEIGHT)];
        [dimensionSlider setMinimumValue:0.0f];
        [dimensionSlider setMaximumValue:1.0f];
        curr_y += RATING_FIELD_HEIGHT;
        dimensionSlider.tag = i++;
        [self.ratingDimensions setObject:dimension forKey:[NSNumber numberWithInt:dimensionSlider.tag]]; // NSNumbers let us put an int into the dictionary
        
        [self.view addSubview:dimensionLabel];
        [self.view addSubview:dimensionSlider];
    }
    // Tell our scroll view how big its contents are, so we can scroll in it.
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             curr_y+(2*RATING_FIELD_HEIGHT));
    

    
}

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setNameLabel:nil];
    [self setBioField:nil];
    [self setScrollView:nil];
    [self setSubmitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)submitButtonPressed:(UIButton *)sender {
    NSMutableDictionary *em = [[NSMutableDictionary alloc] init];
    [em setObject:self.employee.firstName forKey:@"first_name"];
    [em setObject:self.employee.lastName forKey:@"last_name"];
    [em setObject:[NSNumber numberWithInt: self.employee.employee_id] forKey:@"id"];
    
    NSMutableDictionary *ratings = [[NSMutableDictionary alloc] init];
    for( UIView *view in self.view.subviews){
        
        if([view isKindOfClass:[UISlider class]]){
            UISlider *slider = (UISlider *) view;
            
            NSString *dimension = [self.ratingDimensions objectForKey:[NSNumber numberWithInt:slider.tag]];
            
            
            [ratings setObject:[NSNumber numberWithFloat: slider.value] forKey:dimension];
        }
        
    }
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret setObject:em forKey:@"employee"];
    [ret setObject:ratings forKey:@"ratings"];
    [self sendEvaluations:ret];
    
}

- (void) sendEvaluations:(NSDictionary *)dict{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSLog(@"%@", data);
    NSString *URLString = [NSString stringWithFormat:@"%@%@", SERVER_URL, @"/evaluate/"];
    NSString *token = [BusinessLocationsTracker getCSRFTokenFromURL:URLString];
    NSURL *postURL = [[NSURL alloc] initWithString:URLString];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:postURL];
    req.HTTPMethod = @"POST";
    req.HTTPBody = data;
    [req addValue:token forHTTPHeaderField:@"X-CSRFToken"];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *URLResponse, NSData *URLData, NSError *error){
                               if(error){
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"Responses couldn't be posted" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                                   NSLog(@"%@", error);
                                   [alert show];
                                   
                               }
                               else {
                                   
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Your data was successfully posted!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                                   
                                   [alert show];
                               }
                           }];
}
@end
