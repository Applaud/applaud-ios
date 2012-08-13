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
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.title = @"Sign In";
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        // signIning for login success/ failure
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:@"LOGIN_FAILED" object:nil];
        
        // Navbar
        self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.navBar.tintColor = [UIColor grayColor];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(backButtonPressed)];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,44,320,436)];
        self.scrollView.contentSize = CGSizeMake(320, 498);
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        
        [self.navBar pushNavigationItem:self.navigationItem animated:NO];
        [self.view addSubview:self.navBar];
        
        self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plainbackground"]];
        
        UIImageView *smallLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smalllogo"]];
        smallLogo.frame = CGRectMake(135,7, 50, 50);
        
        
        self.username = [self makeTextFieldwithYcoordinate:65 name:@"Email" returnKeyType:UIReturnKeyNext isPassword:NO];
        self.password = [self makeTextFieldwithYcoordinate:103 name:@"Password" returnKeyType:UIReturnKeyGo isPassword:YES];
        
        self.username.keyboardType = UIKeyboardTypeEmailAddress;
        
        // "Sign In" button
        self.signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.signInButton.backgroundColor = [UIColor grayColor];
        self.signInButton.frame = CGRectMake(10,141,TEXTFIELD_WIDTH,TEXTFIELD_HEIGHT);
        
        self.signInButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
        self.signInButton.layer.cornerRadius = 3;
        self.signInButton.layer.borderColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0].CGColor;
        self.signInButton.layer.borderWidth = 1.0;
        
        self.signInButtonLayer = [CAGradientLayer layer];
        self.signInButtonLayer.cornerRadius = 3;
        self.signInButtonLayer.frame = self.signInButton.layer.bounds;
        self.signInButtonLayer.colors = @[(id)[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0].CGColor];
        self.signInButtonLayer.locations = @[@0.0f, @1.0f];
        [self.signInButton addTarget:self action:@selector(signInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.signInButton addTarget:self action:@selector(signInButtonDown) forControlEvents:UIControlEventTouchDown];
        [self.signInButton addTarget:self action:@selector(signInButtonUp) forControlEvents:UIControlEventTouchUpOutside];
    
        
        [self.view addSubview:self.scrollView];
        //[self.scrollView.layer insertSublayer:self.backgroundGradient atIndex:0];
        [self.scrollView addSubview:self.backgroundImage];
        [self.scrollView addSubview:smallLogo];
        [self.scrollView addSubview:self.username];
        [self.scrollView addSubview:self.password];
        [self.scrollView addSubview:self.signInButton];
    }
    return self;
}

-(UITextView *) makeTextFieldwithYcoordinate:(float)height name:(NSString *)name returnKeyType:(UIReturnKeyType)type isPassword:(BOOL)isPassword{
    UITextView *ret = [[UITextView alloc] initWithFrame:CGRectMake(10, height, TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
    ret.layer.cornerRadius = 3;
    ret.layer.borderColor =[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
    ret.layer.borderWidth = 1.0;
    [ret setReturnKeyType:type];
    ret.delegate = self;
    NSLog(@"%d", isPassword);
    ret.secureTextEntry = isPassword;
    ret.autocorrectionType = UITextAutocorrectionTypeNo;
    ret.textColor = [UIColor grayColor];
    ret.font = [UIFont systemFontOfSize:14.0];
    ret.contentInset = UIEdgeInsetsMake(-2.0, 8.0, 0, 0);
    ret.bounces = NO;
    ret.scrollEnabled = NO;
    ret.text = name;
    ret.autocapitalizationType = UITextAutocapitalizationTypeNone;
    return ret;
}

- (void) signInButtonDown {
    if([self checkFields]){
        [self.signInButtonLayer removeFromSuperlayer];
        self.signInButton.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0];
    }
}

-(void) signInButtonUp {
    if([self checkFields]){
        [self.signInButton.layer insertSublayer:self.signInButtonLayer atIndex:0];
    }
}


-(NSString *) placeholderText:(UITextView *)textView{
    NSString *placeholder;
    
    if(textView == self.username){
        placeholder = @"Email";
    }
    else if(textView == self.password){
        placeholder = @"Password";
    }
    
    return placeholder;
}


-(BOOL) checkFields {
    if([self.username.text isEqualToString:@""] || [self.username.text isEqualToString:@"Email"] ){
        return NO;
    }
    if([self.password.text isEqualToString:@""] || [self.password.text isEqualToString:@"Password"] ){
        return NO;
    }
    
    return YES;
}

-(void)usernameTimerCalled:(NSTimer *)timer{
    [self setupSignInButton];
}

-(void)passwordTimerCalled:(NSTimer *)timer{
    [self setupSignInButton];
}


-(void) setupSignInButton{
    if([self checkFields]){
        [self.signInButton.layer insertSublayer:self.signInButtonLayer atIndex:0];
    }
    else{
        [self.signInButtonLayer removeFromSuperlayer];
    }
}

- (void) signInButtonPressed {
    if([self checkFields]){
        [ConnectionManager authenticateWithUsername:self.username.text password:self.password.text];
        [self.password resignFirstResponder];
        [self.username resignFirstResponder];
    }
}

-(void)backButtonPressed {
    [self dismissModalViewControllerAnimated:YES];
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

-(void) textViewDidChange:(UITextView *)textView {
    if(textView == self.username){
        [self.usernameTimer invalidate];
        self.usernameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(usernameTimerCalled:) userInfo:nil repeats:NO];
    }
    else if( textView == self.password ){
        [self.passwordTimer invalidate];
        self.passwordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(passwordTimerCalled:) userInfo:nil repeats:NO];
    }
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        if(textView == self.username){
            [self.password becomeFirstResponder];
        }
        else if(textView == self.password){
            [self.password resignFirstResponder];
            // Scroll back down
            [UIView animateWithDuration:.25 animations:^(void){
                self.scrollView.bounds = CGRectMake(0, 0, self.scrollView.frame.size
                                                    .width, self.scrollView.frame.size.height);
                
            }];
            [self signInButtonPressed];
        }
        return NO;
    }
    return YES;
}

-(BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    if(textView.textColor == [UIColor grayColor]){
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView{
    if(textView.text.length == 0){
        textView.textColor = [UIColor grayColor];
        textView.text = [self placeholderText:textView];
        
    }
    
}


/*
 * resign keyboard on 'return'
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//     [textField resignFirstResponder];
    if( [textField isEqual:self.username]){
        [self.password becomeFirstResponder];
        
    } else{
        [textField resignFirstResponder];
        [self signInButtonPressed];
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
