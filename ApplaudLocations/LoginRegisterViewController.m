//
//  LoginRegisterViewController.m
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "LoginRegisterViewController.h"

@implementation LoginRegisterViewController

- (id)init
{
    self = [super init];
    
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded:) name:@"LOGIN_SUCCESS" object:nil];
        
        self.signIn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.signIn.frame = CGRectMake(100,100,100,100);
        [self.signIn addTarget:self action:@selector(signInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.createAccount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.createAccount.frame = CGRectMake(100,250,100,100);
        [self.createAccount addTarget:self action:@selector(createAccountButtonPressed) forControlEvents:UIControlEventTouchUpInside];

        
        [self.view addSubview: self.signIn];
        [self.view addSubview: self.createAccount];
    }
    
    return self;
}

- (void) signInButtonPressed
{
    
    SignInViewController *SIVC = [[SignInViewController alloc] init];
    SIVC.window = self.window;
    SIVC.appDelegate = self.appDelegate;
    
    [self.navigationController pushViewController:SIVC  animated:YES];
}

- (void) createAccountButtonPressed
{
    RegistrationViewController *RVC = [[RegistrationViewController alloc] init];
    RVC.window = self.window;
    RVC.appDelegate = self.appDelegate;
    
    [self.navigationController pushViewController:RVC animated:YES];
    
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
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


/*
 * Login was completely successful.
 */
- (void)loginSucceeded:(NSNotification *)notification {
    NSLog(@"loginSucceeded called.");
    NSArray *userPassword = notification.object;
    self.appDelegate.settings.username = userPassword[0];
    self.appDelegate.settings.password = userPassword[1];
    NSError *err;
    [self.appDelegate.managedObjectContext save:&err];
    
    self.window.rootViewController = self.appDelegate.navControl;
    
}

@end
