//
//  RegistrationViewController.m
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "RegistrationViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.email = [[UITextField alloc] initWithFrame:CGRectMake(10,10,TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
        self.email.layer.cornerRadius = 5;
        self.email.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.email.layer.borderWidth = 2.0;
        [self.email setReturnKeyType:UIReturnKeyNext];
        self.email.delegate = self;
        self.email.autocorrectionType = UITextAutocorrectionTypeNo;
        
        
        self.firstName = [[UITextField alloc] initWithFrame:CGRectMake(10,50,TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
        self.firstName.layer.cornerRadius = 5;
        self.firstName.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.firstName.layer.borderWidth = 2.0;
        [self.firstName setReturnKeyType:UIReturnKeyNext];
        self.firstName.delegate = self;
        self.firstName.autocorrectionType = UITextAutocorrectionTypeNo;
        
        
        self.lastName = [[UITextField alloc] initWithFrame:CGRectMake(10,90,TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
        self.lastName.layer.cornerRadius = 5;
        self.lastName.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.lastName.layer.borderWidth = 2.0;
        [self.lastName setReturnKeyType:UIReturnKeyNext];
        self.lastName.delegate = self;
        self.lastName.autocorrectionType = UITextAutocorrectionTypeNo;
        
        
        self.password = [[UITextField alloc] initWithFrame:CGRectMake(10,130,TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
        self.password.layer.cornerRadius = 5;
        self.password.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.password.layer.borderWidth = 2.0;
        [self.password setReturnKeyType:UIReturnKeyNext];
        self.password.delegate = self;
        self.password.autocorrectionType = UITextAutocorrectionTypeNo;
        self.password.secureTextEntry = YES;
        
        
        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [registerButton setTitle:@"Register" forState:UIControlStateNormal];
        registerButton.frame = CGRectMake(10,170, TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT);
        [registerButton addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.email];
        [self.view addSubview:self.firstName];
        [self.view addSubview:self.lastName];
        [self.view addSubview:self.password];
        [self.view addSubview:registerButton];
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

- (void) registerButtonPressed
{
    NSDictionary *dict = @{@"email":self.email.text,
                 @"first_name":self.firstName.text,
                   @"last_name":self.lastName.text,
                    @"password":self.password.text};
    
    [ConnectionManager serverRequest:@"POST" withParams:dict url:REGISTER_URL callback:^(NSHTTPURLResponse *response, NSData *data){
        [ConnectionManager authenticateWithUsername:dict[@"email"] password:dict[@"password"]];
    }];
    
}

@end
