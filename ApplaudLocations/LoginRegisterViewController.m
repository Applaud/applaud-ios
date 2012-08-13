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
        
//        self.backgroundGradient = [CAGradientLayer layer];
//        self.backgroundGradient.frame = CGRectMake(0,0,320,460);
//        self.backgroundGradient.colors = @[(id)[UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor];
//        self.backgroundGradient.locations = @[@0.0, @1.0f];
//        
        // Logo image
//        self.logo = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"transparent logo"]];
//        self.logo.frame = CGRectMake(10, -20, 300, 300);
//        
//        // Title
//        self.apatapaTitle = [[UILabel alloc] initWithFrame: CGRectMake(40,275,300,50)];
//        self.apatapaTitle.text = @"APATAPA";
//        self.apatapaTitle.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
//        self.apatapaTitle.textColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0];
//        self.apatapaTitle.font = [UIFont boldSystemFontOfSize:50];
//        
        
        // Sign-In button setup and styling
        self.signIn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.signIn.backgroundColor = [UIColor grayColor];
        self.signIn.frame = CGRectMake(10,412,TEXTFIELD_WIDTH,TEXTFIELD_HEIGHT);
        self.signIn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.signIn setTitle:@"Sign In" forState:UIControlStateNormal];
        self.signIn.layer.cornerRadius = 3;
        self.signIn.layer.borderColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0].CGColor;
        self.signIn.layer.borderWidth = 1.0;

        self.signInLayer = [CAGradientLayer layer];
        self.signInLayer.frame = self.signIn.layer.bounds;
        self.signInLayer.colors = @[(id)[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0].CGColor];
        self.signInLayer.locations = @[@0.0f, @1.0f];
        self.signInLayer.cornerRadius = 3;

        //[self.signIn.layer addSublayer:self.signInLayer];
        [self.signIn.layer insertSublayer:self.signInLayer atIndex:0];
        [self.signIn addTarget:self action:@selector(signInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.signIn addTarget:self action:@selector(signInButtonDown) forControlEvents:UIControlEventTouchDown];
        [self.signIn addTarget:self action:@selector(signInButtonUp) forControlEvents:UIControlEventTouchUpOutside];
        
        
        // Create Account button setup and styling
        self.createAccount = [UIButton buttonWithType:UIButtonTypeCustom];
        self.createAccount.frame = CGRectMake(10,370,TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT);
        self.createAccount.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.createAccount setTitle:@"Create an Account" forState:UIControlStateNormal];
        self.createAccount.layer.cornerRadius = 3;
        self.createAccount.layer.borderColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0].CGColor;
        self.createAccount.layer.borderWidth = 1.0;
        
        self.createAccountLayer = [CAGradientLayer layer];
        self.createAccountLayer.frame = self.createAccount.layer.bounds;
        self.createAccountLayer.colors = @[(id)[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0].CGColor];
        self.createAccountLayer.locations = @[@0.0f, @1.0f];
        self.createAccountLayer.cornerRadius = 3;
        
        [self.createAccount.layer insertSublayer:self.createAccountLayer atIndex:0];
        [self.createAccount addTarget:self action:@selector(createAccountButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.createAccount addTarget:self action:@selector(createAccountButtonDown) forControlEvents:UIControlEventTouchDown];
        [self.createAccount addTarget:self action:@selector(createAccountButtonUp) forControlEvents:UIControlEventTouchUpOutside];
        

        //[self.view addSubview:self.backgroundImage];
        //[self.view.layer insertSublayer:self.backgroundGradient atIndex:0];
        [self.view addSubview:self.backgroundImage];
        [self.view addSubview:self.apatapaTitle];
        [self.view addSubview:self.logo];
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
    [self.signIn.layer insertSublayer:self.signInLayer atIndex:0];
}

-(void) createAccountButtonDown {
    [self.createAccountLayer removeFromSuperlayer];
    self.createAccount.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0];
}

-(void)createAccountButtonUp {
    [self.createAccount.layer insertSublayer:self.createAccountLayer atIndex:0];
}

- (void) signInButtonPressed
{
    [self.signIn.layer insertSublayer:self.signInLayer atIndex:0];
    SignInViewController *SIVC = [[SignInViewController alloc] init];
    SIVC.window = self.window;
    SIVC.appDelegate = self.appDelegate;
    [self presentViewController:SIVC animated:YES completion:nil];
}

- (void) createAccountButtonPressed
{
    [self.createAccount.layer insertSublayer:self.createAccountLayer atIndex:0];
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
    
    UIView *newView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plainbackground"]];
    [self.window addSubview:newView];
    
    self.window.rootViewController = self.appDelegate.navControl;
    
}

@end
