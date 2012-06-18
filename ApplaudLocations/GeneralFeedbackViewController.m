//
//  GeneralFeedbackViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/17/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "GeneralFeedbackViewController.h"

@interface GeneralFeedbackViewController ()

@end

@implementation GeneralFeedbackViewController
@synthesize navigationController = _navigationController;
@synthesize questionLabel;
@synthesize textField;

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
    // Do any additional setup after loading the view from its nib.
    self.questionLabel.text = @"Leave Comment";
    self.textField.delegate = self;
}

- (void)viewDidUnload
{
    [self setQuestionLabel:nil];

    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 * Sends the general feedback response to the server. URL and JSON will be changed when
 * the server is ready.
 */
- (void)sendResponse:(NSString *)response {
    NSString *urlString = [NSString stringWithFormat:SERVER_URL, @"/general_feedback"];
    NSURL *url = [[NSURL alloc] initWithString:urlString];      
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"answer", nil];
    NSArray *objs = [[NSArray alloc] initWithObjects:self.textField.text, nil];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:objs forKeys:keys];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    request.HTTPBody = data;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *d, NSError *err) {
                               if(err) {
                                   [[[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                               message:@"Couldn't send response."
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil] show];
                               }
                           }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)field {
    [field resignFirstResponder];
    return YES;
}

- (IBAction)doneEditing:(UITextField *)sender {
    [self sendResponse:sender.text];
    [sender resignFirstResponder];
}
@end
