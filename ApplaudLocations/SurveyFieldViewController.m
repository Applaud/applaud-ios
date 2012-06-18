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
@synthesize questionLabel = _questionLabel;

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
    self.questionLabel.text = self.field.label;
    // Load up the appropriate view, based upon the field type.
    // The curly braces are necessary to make the compiler happy.
    switch(self.field.type) {
        case TEXTAREA:
        {
            [self addTextArea];
        }
            break;
        case TEXTFIELD:
        {
            [self addTextField];
        }
            break;
        case RADIO:
        {
            [self addRadioGroup];
        }
            break;
        case CHECKBOX:
        {
            [self addCheckBoxGroup];
        }
            break;
    }
}

- (void)viewDidUnload
{
    [self setQuestionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma Adding Views

- (void)addTextField {
    UITextField *field = [[UITextField alloc] initWithFrame:
                          CGRectMake(0,
                                     0,
                                     self.view.frame.size.width,
                                     WIDGET_HEIGHT)];
    field.backgroundColor = [UIColor redColor];
    [self.view addSubview:field];
}

- (void)addTextArea {
    
}

- (void)addRadioGroup {
    
}

- (void)addCheckBoxGroup {
    
}
@end
