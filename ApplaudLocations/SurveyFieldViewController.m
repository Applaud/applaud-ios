//
//  SurveyFieldViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/17/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "SurveyFieldViewController.h"

@interface SurveyFieldViewController ()

@end

@implementation SurveyFieldViewController

@synthesize field = _field;
@synthesize titleLabel = _titleLabel;

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
    self.titleLabel.text = self.field.label;
    
    // Load up the appropriate view, based upon the field type.
    // The curly braces are necessary to make the compiler happy.
    switch(self.field.type) {
        case TEXTAREA:

            break;
        case TEXTFIELD:
        {
            UITextField *field = [[UITextField alloc] initWithFrame:
/*                                  CGRectMake(0,
                                             WIDGET_BEGIN,
                                             self.view.frame.size.width,
                                             WIDGET_HEIGHT)];*/
                                  CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
            [self.view addSubview:field];
        }
            break;
        case RADIO:
        {
            
        }
            break;
        case CHECKBOX:
        {
            
        }
            break;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
