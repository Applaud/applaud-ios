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
@synthesize labels = _labels; // For relating checkbox groups to their labels.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _labels = [[NSMutableArray alloc] init];
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
 * Called when the back button is pressed. This allows us to set the answer to this question in the Survey object.
 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UINavigationController *parent = (UINavigationController *)self.parentViewController;
    QuestionsViewController *qvc = [parent.viewControllers objectAtIndex:0];
    // Find the index at which this question is located.
    NSUInteger row = [qvc.survey.fields indexOfObject:self.field];
    NSArray *answer = [self getAnswer];
    if(answer) {
        [qvc.survey.answers replaceObjectAtIndex:row withObject:answer];
        UITableViewCell *answerCell = [qvc.questionsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        answerCell.detailTextLabel.text = [answer componentsJoinedByString:@", "];
//        answerCell.contentView.backgroundColor = [UIColor greenColor];
    }
    [qvc.questionsTable reloadData];        
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
    int i = 0;
    for(NSString *option in self.field.options) {
        UISwitch *checkbox = [[UISwitch alloc] initWithFrame:CGRectMake(20,
                                                                      currenty,
                                                                      50,
                                                                      WIDGET_HEIGHT)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100,
                                                                   currenty - 15,
                                                                   self.view.frame.size.width - 120,
                                                                   WIDGET_HEIGHT/2)];
        // Give it the right color.
        label.opaque = YES;
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        label.textAlignment = UITextAlignmentCenter;
        label.text = option;
        currenty += WIDGET_HEIGHT + 10;
        // Associate the checkbox with its question string.
        checkbox.tag = i++;
        [self.labels addObject:label.text];
        [self.view addSubview:label];
        [self.view addSubview:checkbox];
    }
}

#pragma mark -
#pragma Getting answers

/*
 * Gets the user's answers, based on the type of widget that this question uses.
 * This returns an NSArray because the server is expecting that in JSON, plus
 * the checkboxes may have multiple answers.
 */
- (NSArray *)getAnswer {
    switch(self.field.type) {
        case TEXTAREA:
        {
            UITextView *textView;
            for(UIView *view in self.view.subviews) {
                if([view isKindOfClass:[UITextView class]]) {
                    textView = (UITextView *)view;
                    if(textView.text) {
                        return [NSArray arrayWithObject:textView.text];
                    }
                }
            }
        }
            break;
        case TEXTFIELD:
        {
            UITextField *textField;
            for(UIView *view in self.view.subviews) {
                if([view isKindOfClass:[UITextField class]]) {
                    textField = (UITextField *)view;
                    if(textField.text) {
                        return [NSArray arrayWithObject:textField.text];
                    }
                }
            }
        }
            break;
        case RADIO:
        {
            UISegmentedControl *radioGroup;
            for(UIView *view in self.view.subviews) {
                if([view isKindOfClass:[UISegmentedControl class]]) {
                    radioGroup = (UISegmentedControl *)view;
                    if(radioGroup.selectedSegmentIndex != UISegmentedControlNoSegment) {
                        return [NSArray arrayWithObject:[radioGroup titleForSegmentAtIndex:radioGroup.selectedSegmentIndex]];
                    }
                }
            }
        }
            break;
        case CHECKBOX:
        {
            NSMutableArray *checkboxen = [[NSMutableArray alloc] init];
            for(UIView *view in self.view.subviews) {
                if([view isKindOfClass:[UISwitch class]]) {
                    [checkboxen addObject:(UISwitch *)view];
                }
            }
            NSMutableArray *answers = [[NSMutableArray alloc] init];
            for(UISwitch *box in checkboxen) {
                // If the box is checked, find its associated label and put it into the answers array.
                if(box.isOn) {
                    [answers addObject:[self.labels objectAtIndex:box.tag]];
                }
            }
            if(answers.count) {
                return answers;
            }
        }
            break;
    }
    return nil; // If we don't have an answer.
}
@end
