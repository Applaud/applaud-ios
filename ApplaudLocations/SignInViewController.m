//
//  SignInViewController.m
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "SignInViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface SignInViewController ()

@end

@implementation SignInViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Sign In";
        
        // Registering for login success/ failure

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:@"LOGIN_FAILED" object:nil];
        
        // Username textfield
        self.username = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
        self.username.layer.cornerRadius = 3;
        self.username.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.username.layer.borderWidth = 2.0;
        [self.username setReturnKeyType:UIReturnKeyNext];
        self.username.delegate = self;
        self.username.autocorrectionType = UITextAutocorrectionTypeNo;
        
        // Password textfield
        self.password = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
        self.password.secureTextEntry = YES;
        self.password.layer.cornerRadius = 3;
        self.password.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.password.layer.borderWidth = 2.0;
        [self.password setReturnKeyType:UIReturnKeyGo];
        self.password.delegate = self;
        
        // "Sign In" button
        UIButton *signInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        signInButton.frame = CGRectMake(10, 90, 300, 30);
        [signInButton addTarget:self action:@selector(signInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.username];
        [self.view addSubview:self.password];
        [self.view addSubview:signInButton];
    }
    return self;
}

- (void) signInButtonPressed
{
    [ConnectionManager authenticateWithUsername:self.username.text password:self.password.text];
    
    
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


#pragma mark -
#pragma mark Login Success/Failure Methods

- (void) loginFailed: (NSNotification *) notification {
    
    [[[UIAlertView alloc] initWithTitle:@"Error"
                               message:@"Invalid Credentials\nTry Again?"
                              delegate:nil
                     cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}


#pragma mark -
#pragma mark Delegate Methods from UITextView/Field

/*
 * resign keyboard on 'return'
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//     [textField resignFirstResponder];
    if( [textField isEqual:self.username]){
        [self.password becomeFirstResponder];
        
    } else{
        [textField resignFirstResponder];
        [ConnectionManager authenticateWithUsername:self.username.text password:self.password.text];
    }
    
    return NO;
}

/*
 * resign keyboard on 'return'
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {
    return YES;
}

@end
