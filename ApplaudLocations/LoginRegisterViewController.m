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
        self.navigationItem.title = @"Foobar";
        // Background image
        self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
        self.backgroundImage.contentMode = UIViewContentModeBottom;
        self.backgroundImage.frame = CGRectMake(0, -44, self.view.frame.size.width, self.view.frame.size.height);
        
        // Logo image
        self.logo = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"transparent logo"]];
        self.logo.frame = CGRectMake(10, 50, 300, 300);
        
        self.signIn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.signIn.backgroundColor = [UIColor whiteColor];
        self.signIn.frame = CGRectMake(10,336,TEXTFIELD_WIDTH,TEXTFIELD_HEIGHT);
        self.signIn.layer.cornerRadius = 0;
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.signIn.layer.bounds;
        gradientLayer.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0].CGColor];
        gradientLayer.locations = @[@0.0f, @1.0f];
        [self.signIn.layer addSublayer:gradientLayer];
        
        [self.signIn addTarget:self action:@selector(signInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.createAccount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.createAccount.frame = CGRectMake(10,376,TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT);
        [self.createAccount addTarget:self action:@selector(createAccountButtonPressed) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:self.backgroundImage];
        //[self.view addSubview:self.logo];
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
