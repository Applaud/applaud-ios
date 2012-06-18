//
//  SurveyFieldViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/17/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

// TODO: override viewWillDisappear: to set answers

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
    [self setField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 * Called when the back button is pressed. This allows us to set the answer to this question.
 */
- (void)viewWillDisappear:(BOOL)animated {
    UINavigationController *parent = (UINavigationController *)self.parentViewController;
    NSLog(@"%@", [parent.viewControllers objectAtIndex:0]);
}

#pragma mark -
#pragma Adding Views

/*
 * Load up a text field.
 */
- (void)addTextField {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(20,
                                                                       WIDGET_BEGIN,
                                                                       self.view.frame.size.width - 40,
                                                                       WIDGET_HEIGHT/4)];
    /* Gives the text area a border -- had to #import Quartz to do so. */
    field.layer.cornerRadius = 5;
    field.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    field.layer.borderWidth = 2.0;
    [self.view addSubview:field];
}

/*
 * Load up a text area.
 */
- (void)addTextArea {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20,
                                                                         WIDGET_BEGIN,
                                                                         self.view.frame.size.width - 40,
                                                                         WIDGET_HEIGHT)];
    /* Gives the text area a border -- had to #import Quartz to do so. */
    textView.layer.cornerRadius = 5;
    textView.clipsToBounds = YES;
    textView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    textView.layer.borderWidth = 2.0;
    [self.view addSubview:textView];    
}

/*
 * Create a radio group. This is a UISegmentedControl.
 */
- (void)addRadioGroup {
    
    UISegmentedControl *radioGroup = [[UISegmentedControl alloc] initWithItems:self.field.options];
    radioGroup.frame = CGRectMake(self.view.frame.size.width/4,
                                  WIDGET_BEGIN,
                                  self.view.frame.size.width/2,
                                  WIDGET_HEIGHT/2);
    [self.view addSubview:radioGroup];
}

/*
 * Create a bunch of check boxes (actually switches).
 */
- (void)addCheckBoxGroup {
    int currenty = WIDGET_BEGIN;
    for(NSString *option in self.field.options) {
/*        UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        checkButton.frame = CGRectMake(20,
                                       currenty,
                                       50,
                                       WIDGET_HEIGHT/2);*/
        /* Lets us change the background on click. */
//        [checkButton addTarget:self action:@selector(buttonChecked:) forControlEvents:UIControlEventTouchUpInside];
        UISwitch *checkbox = [[UISwitch alloc] initWithFrame:CGRectMake(20,
                                                                      currenty,
                                                                      50,
                                                                      WIDGET_HEIGHT)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100,
                                                                   currenty - 10,
                                                                   self.view.frame.size.width - 120,
                                                                   WIDGET_HEIGHT/2)];
        label.text = option;
//        checkButton.backgroundColor = [UIColor greenColor];
        currenty += WIDGET_HEIGHT + 10;
//        [self.view addSubview:checkButton];
        [self.view addSubview:label];
        [self.view addSubview:checkbox];
    }
}

#pragma mark -
#pragma Checkbox delegate

/*
 * When the button is pressed, change its background color.
 */
- (void)buttonChecked:(id)sender {
    UIButton *button = (UIButton *)sender;
    if([button.backgroundColor isEqual:[UIColor greenColor]]) {
        button.backgroundColor = [UIColor blueColor];
    }
    else {
        button.backgroundColor = [UIColor greenColor];   
    }
}
@end
