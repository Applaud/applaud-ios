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

        // Background image
        self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
        self.backgroundImage.contentMode = UIViewContentModeBottom;
        self.backgroundImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        // Logo image
        //self.logo = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"transparent logo"]];
        //self.logo.frame = CGRectMake(10, 50, 300, 300);
        
        
        // Sign-In button setup and styling
        self.signIn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.signIn.backgroundColor = [UIColor grayColor];
        self.signIn.frame = CGRectMake(10,390,TEXTFIELD_WIDTH,TEXTFIELD_HEIGHT);
        // [self.signIn setTitle:@"Sign In" forState:UIControlStateNormal];
        [self.signIn setTitle:@"Sign In" forState:UIControlStateNormal];
        self.signIn.layer.cornerRadius = 1;
        self.signIn.layer.borderColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0].CGColor;
        self.signIn.layer.borderWidth = 1.0;

        self.signInLayer = [CAGradientLayer layer];
        self.signInLayer.frame = self.signIn.layer.bounds;
        self.signInLayer.colors = @[(id)[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0].CGColor];
        self.signInLayer.locations = @[@0.0f, @1.0f];

        [self.signIn.layer addSublayer:self.signInLayer];
        [self.signIn addTarget:self action:@selector(signInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.signIn addTarget:self action:@selector(signInButtonDown) forControlEvents:UIControlEventTouchDown];
        [self.signIn addTarget:self action:@selector(signInButtonUp) forControlEvents:UIControlEventTouchUpOutside];
        
        
        // Create Account button setup and styling
        self.createAccount = [UIButton buttonWithType:UIButtonTypeCustom];
        self.createAccount.frame = CGRectMake(10,422,TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT);
        [self.createAccount setTitle:@"Create an Account" forState:UIControlStateNormal];
        self.createAccount.layer.cornerRadius = 1;
        self.createAccount.layer.borderColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0].CGColor;
        self.createAccount.layer.borderWidth = 1.0;
        
        self.createAccountLayer = [CAGradientLayer layer];
        self.createAccountLayer.frame = self.createAccount.layer.bounds;
        self.createAccountLayer.colors = @[(id)[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0].CGColor];
        self.createAccountLayer.locations = @[@0.0f, @1.0f];
        
        [self.createAccount.layer addSublayer:self.createAccountLayer];
        [self.createAccount addTarget:self action:@selector(createAccountButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.createAccount addTarget:self action:@selector(createAccountButtonDown) forControlEvents:UIControlEventTouchDown ];
        

        [self.view addSubview:self.backgroundImage];
        //[self.view addSubview:self.logo];
        [self.view addSubview: self.signIn];
        [self.view addSubview: self.createAccount];
    }
    
    return self;
}

- (void) signInButtonDown {
    [self.signInLayer removeFromSuperlayer];
    self.signIn.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0];
}

-(void) signInButtonUp {
    [self.signIn.layer addSublayer:self.signInLayer];
    [self.signIn setTitle:@"foo" forState:UIControlStateNormal];
}

-(void) createAccountButtonDown {
    self.createAccount.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0];
}

- (void) signInButtonPressed
{
    [self.signIn.layer addSublayer:self.signInLayer];
    SignInViewController *SIVC = [[SignInViewController alloc] init];
    SIVC.window = self.window;
    SIVC.appDelegate = self.appDelegate;
    [self presentViewController:SIVC animated:YES completion:nil];
}

- (void) createAccountButtonPressed
{
    RegistrationViewController *RVC = [[RegistrationViewController alloc] init];
    RVC.window = self.window;
    RVC.appDelegate = self.appDelegate;
    [self presentViewController:RVC animated:YES completion:nil];
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
