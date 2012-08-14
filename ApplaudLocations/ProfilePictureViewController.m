//
//  ProfilePictureViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ProfilePictureViewController.h"

@interface ProfilePictureViewController ()

@end

@implementation ProfilePictureViewController

-(id)initWithUsername:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if (self) {
        self.username = username;
        self.password = password;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:@"LOGIN_SUCCESS"
                                                   object:nil];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0,
                                                                        320, 44)];
        self.navBar.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                         target:self
                                         action:@selector(cameraButtonPressed)];
        self.navigationItem.rightBarButtonItem = cameraButton;
        self.navigationItem.title = @"Profile Picture";
        [self.navBar pushNavigationItem:self.navigationItem animated:NO];
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.allowsEditing = NO;
        }
        self.text = [[UILabel alloc] init];
        self.text.text = @"You can add a (totally optional) picture to your profile here.";
        self.text.font = [UIFont systemFontOfSize:14.0f];
        self.text.lineBreakMode = UILineBreakModeWordWrap;
        self.text.numberOfLines = 0;
        self.text.frame = CGRectMake(10, 65, TEXTFIELD_WIDTH, 40);
        self.text.backgroundColor = [UIColor clearColor];
        self.noPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.noPictureButton.frame = CGRectMake(10, 103,
                                                TEXTFIELD_WIDTH,
                                                TEXTFIELD_HEIGHT);
        [self.noPictureButton setTitle:@"No thanks!" forState:UIControlStateNormal];
        self.noPictureButton.backgroundColor = [UIColor colorWithRed:.8
                                                               green:.8
                                                                blue:.8
                                                               alpha:1.0];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.cornerRadius = 3;
        gradient.frame = self.noPictureButton.layer.bounds;
        gradient.colors = @[(id)[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0].CGColor,
                            (id)[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0].CGColor];
        gradient.locations = @[@0.0, @1.0];
        [self.noPictureButton addTarget:self
                                 action:@selector(noPictureButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
        [self.noPictureButton.layer insertSublayer:gradient atIndex:0];
        UIImageView *smallLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smalllogo"]];
        smallLogo.frame = CGRectMake(135, 51, 50, 50);
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plainbackground"]];
        backgroundImage.frame = CGRectMake(0, 0, 320, 460);
        [self.view addSubview:backgroundImage];
        [self.view addSubview:self.navBar];
        [self.view addSubview:self.noPictureButton];
        [self.view addSubview:self.text];
        [self.view addSubview:smallLogo];
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
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma mark Image picker delegate methods

/*
 * When we get the image, we store it and wait until we're signed in.
 * This is because Django needs us to have a user ID in the database before
 * we can save the picture. So once we've successfully logged in, we go to
 * notificationReceived: and send the image.
 */
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = [[image normalizedImage] resizedImage];
    [ConnectionManager authenticateWithUsername:self.username password:self.password];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Other methods

-(void)noPictureButtonPressed {
    [ConnectionManager authenticateWithUsername:self.username password:self.password];
}

-(void)notificationReceived:(NSNotification *)notification {
    if([notification.name isEqualToString:@"LOGIN_SUCCESS"]) {
        [ConnectionManager postPhoto:self.image
                          withParams:nil
                            callback:nil
                               toURL:SET_PROFILE_PICTURE_URL];
    }
}

-(void)cameraButtonPressed {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

@end
