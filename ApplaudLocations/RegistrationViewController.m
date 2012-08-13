//
//  RegistrationViewController.m
//  ApplaudIOS
//
//  Created by Robert Kearney on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "RegistrationViewController.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,44,320,436)];
        self.scrollView.contentSize = CGSizeMake(320, 498);
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.title = @"Registration";
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(backButtonPressed)];
        self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.navBar.tintColor = [UIColor grayColor];
        
        [self.navBar pushNavigationItem:self.navigationItem animated:NO];
        
        self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plainbackground"]];
        
        UIImageView *smallLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smalllogo"]];
        smallLogo.frame = CGRectMake(135,7, 50, 50);
        
        self.email = [self makeTextFieldwithYcoordinate:62 name:@"Email" returnKeyType:UIReturnKeyNext isPassword:NO];
        self.firstName = [self makeTextFieldwithYcoordinate:100 name:@"First Name" returnKeyType:UIReturnKeyNext isPassword:NO];
        self.lastName = [self makeTextFieldwithYcoordinate:138 name:@"Last Name (optional)" returnKeyType:UIReturnKeyNext isPassword:NO];
        self.password = [self makeTextFieldwithYcoordinate:176 name:@"Password" returnKeyType:UIReturnKeyGo isPassword:YES];
        
        self.email.keyboardType = UIKeyboardTypeEmailAddress;
        
        // Set up status images
        self.emailStatusImage = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGE_SPACING, 7, 20, 20)];
        [self.email addSubview:self.emailStatusImage];
        
        self.passwordStatusImage = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGE_SPACING, 7, 20, 20)];
        [self.password addSubview:self.passwordStatusImage];
        
        
        self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.registerButton.backgroundColor = [UIColor grayColor];
        self.registerButton.frame = CGRectMake(10,218,TEXTFIELD_WIDTH,TEXTFIELD_HEIGHT);
        
        self.registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
        self.registerButton.layer.cornerRadius = 3;
        self.registerButton.layer.borderColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0].CGColor;
        self.registerButton.layer.borderWidth = 1.0;
        
        self.registerButtonLayer = [CAGradientLayer layer];
        self.registerButtonLayer.cornerRadius = 3;
        self.registerButtonLayer.frame = self.registerButton.layer.bounds;
        self.registerButtonLayer.colors = @[(id)[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0].CGColor];
        self.registerButtonLayer.locations = @[@0.0f, @1.0f];
        [self.registerButton addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.registerButton addTarget:self action:@selector(signInButtonDown) forControlEvents:UIControlEventTouchDown];
        [self.registerButton addTarget:self action:@selector(signInButtonUp) forControlEvents:UIControlEventTouchUpOutside];
        
        self.isEmailValid = NO;
        self.isFirstNameValid = NO;
        self.isPasswordValid = NO;
        
        
        [self.view addSubview:self.navBar];
        [self.view addSubview:self.scrollView];
        //[self.scrollView.layer insertSublayer:self.backgroundGradient atIndex:0];
        [self.scrollView addSubview:self.backgroundImage];
        [self.scrollView addSubview:smallLogo];
        [self.scrollView addSubview:self.email];
        [self.scrollView addSubview:self.firstName];
        [self.scrollView addSubview:self.lastName];
        [self.scrollView addSubview:self.password];
        [self.scrollView addSubview:self.registerButton];
    }
    return self;
}

-(UITextView *) makeTextFieldwithYcoordinate:(float)height name:(NSString *)name returnKeyType:(UIReturnKeyType)type isPassword:(BOOL)isPassword{
    UITextView *ret = [[UITextView alloc] initWithFrame:CGRectMake(10, height, TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
    ret.layer.cornerRadius = 3;
    ret.layer.borderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
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
        [self.registerButtonLayer removeFromSuperlayer];
        self.registerButton.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0];
    }
}

-(void) signInButtonUp {
    if([self checkFields]){
        [self.registerButton.layer insertSublayer:self.registerButtonLayer atIndex:0];
    }
}

-(void)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)emailTimerCalled:(NSTimer *)timer{
    [self checkEmail];
}

-(void)passwordTimerCalled:(NSTimer *)timer{
    [self checkPassword];
}

-(void)firstNameTimerCalled:(NSTimer *)timer{
    [self checkFirstName];
}

-(void)checkPassword {
    NSString *password = self.password.text;

    NSError *err;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^\\w{8,30}$"
                                                                      options:0
                                                                        error:&err];
    if(err) NSLog(@"regex error! %@", err);
    int num = [regex numberOfMatchesInString:password
                                     options:0
                                       range:NSMakeRange(0, password.length)];
    // Password is no good
    if(!num){
        self.passwordStatusImage.image = [UIImage imageNamed:@"ExMark"];
        self.isPasswordValid = NO;
    }
    else{
        self.passwordStatusImage.image = [UIImage imageNamed:@"CheckMark"];
        self.isPasswordValid = YES;
    }
    [self setRegisterButton];
}

-(void)checkFirstName {
    if( [self.firstName.text isEqualToString:[self placeholderText:self.firstName]]
          || self.firstName.text.length == 0 ){
        self.isFirstNameValid = NO;
    }
    else {
        self.isFirstNameValid = YES;
        NSLog(@"FIRST NAME %@", self.firstName.text);
    }
    [self setRegisterButton];
}

-(void)checkEmail {
    NSString *email = self.email.text;
    NSDictionary *dict = @{@"email":self.email.text};
    [ConnectionManager serverRequest:@"GET" withParams:dict url:CHECK_EMAIL_URL callback:^(NSHTTPURLResponse *urlResponse, NSData *data){
        NSDictionary *returnData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSError *err;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
                                                                          options:0
                                                                            error:&err];
        if(err){
            NSLog(@"regex error .... email style %@", err);
        }
        int num = [regex numberOfMatchesInString:email
                                         options:0
                                           range:NSMakeRange(0, email.length)];
        
        NSLog(@"num is...  %d",num);
        NSLog(@"returnData['does_exist'].... %@", returnData[@"does_exist"]);
        
        //Email already exists or isn't valid
        if([returnData[@"does_exist"] boolValue] || (! num)){
            self.emailStatusImage.image = [UIImage imageNamed:@"ExMark"];
            self.isEmailValid = NO;
        }
        else{
            self.emailStatusImage.image = [UIImage imageNamed:@"CheckMark"];
            self.isEmailValid = YES;
        }
        [self setRegisterButton];
    }];
}

-(BOOL) checkFields{
    if(self.isEmailValid && self.isPasswordValid && self.isFirstNameValid){
        return YES;
    }
    else {
        return NO;
    }
}

-(void) setRegisterButton{
    if([self checkFields]){
        [self.registerButton.layer insertSublayer:self.registerButtonLayer atIndex:0];
    }
    else{
        [self.registerButtonLayer removeFromSuperlayer];
    }
}
- (void) registerButtonPressed {
    if([self checkFields]){
        NSString *lastName = self.lastName.text ? self.lastName.text: @"";
        NSDictionary *dict = @{@"email":self.email.text,
        @"first_name":self.firstName.text,
        @"last_name":lastName,
        @"password":self.password.text};
        
        [ConnectionManager serverRequest:@"POST" withParams:dict url:REGISTER_URL callback:^(NSHTTPURLResponse *response, NSData *data){
            
            ProfilePictureViewController *ppvc = [[ProfilePictureViewController alloc]
                                                  initWithUsername:self.email.text
                                                  password:self.password.text];
            [self presentViewController:ppvc animated:YES completion:nil];
        }];
    }
}


-(NSString *) placeholderText:(UITextView *)textView{
    NSString *placeholder;
    
    if(textView == self.email){
        placeholder = @"Email";
    }
    else if(textView == self.firstName){
        placeholder = @"First Name";
    }
    else if(textView == self.lastName){
        placeholder = @"Last Name (optional)";
    }
    else if(textView == self.password){
        placeholder = @"Password";
    }
    
    return placeholder;
}

-(void) textViewDidChange:(UITextView *)textView {
    if(textView == self.email){
        [self.emailTimer invalidate];
        self.emailTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(emailTimerCalled:) userInfo:nil repeats:NO];
    }
    else if( textView == self.password ){
        [self.passwordTimer invalidate];
        self.passwordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(passwordTimerCalled:) userInfo:nil repeats:NO];
    }
    else if( textView == self.firstName){
        [self.firstNameTimer invalidate];
        self.firstNameTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(firstNameTimerCalled:) userInfo:nil repeats:NO];
    }
}

-(void) textViewDidBeginEditing:(UITextView *)textView{
    
    [UIView animateWithDuration:.25 animations:^(void){
       self.scrollView.bounds = CGRectMake(0, 58, self.scrollView.frame.size
                                           .width, self.scrollView.frame.size.height);
        
    }];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        if(textView == self.email){
            [self.firstName becomeFirstResponder];
        }
        else if(textView == self.firstName){
            [self.lastName becomeFirstResponder];
        }
        else if(textView == self.lastName){
            [self.password becomeFirstResponder];
        }
        else if(textView == self.password){
            [self.password resignFirstResponder];
            // Scroll back down
            [UIView animateWithDuration:.25 animations:^(void){
                self.scrollView.bounds = CGRectMake(0, 0, self.scrollView.frame.size
                                                    .width, self.scrollView.frame.size.height);
                
            }];
            [self registerButtonPressed];
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
    [self checkFirstName];
    
    if(textView.text.length == 0){
        textView.textColor = [UIColor grayColor];
        textView.text = [self placeholderText:textView];
        
        // If clicked out of textView when there isn't any text, don't continue to display status image
        if( textView == self.email ){
            self.emailStatusImage.image = nil;
        }
        else if( textView == self.password ){
            self.passwordStatusImage.image = nil;
        }
    }
    
}

@end
