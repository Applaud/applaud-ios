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
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                         target:self
                                         action:@selector(cameraButtonPressed)];
        self.navigationItem.rightBarButtonItem = cameraButton;
        [self.navBar pushNavigationItem:self.navigationItem animated:NO];
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.allowsEditing = NO;
        }
        self.text = [[UILabel alloc] init];
        self.text.text = @"You can add a (totally option) picture to your profile here.";
        self.text.font = [UIFont systemFontOfSize:14.0f];
        self.text.lineBreakMode = UILineBreakModeWordWrap;
        self.text.numberOfLines = 0;
        CGSize size = [self.text.text sizeWithFont:[UIFont systemFontOfSize:14.0f]
                                 constrainedToSize:CGSizeMake(self.text.frame.size.width,
                                                              1000)
                                     lineBreakMode:UILineBreakModeWordWrap];
        self.text.frame = CGRectMake(10, 64, TEXTFIELD_WIDTH, size.height);
        self.noPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.noPictureButton.frame = CGRectMake(10,
                                                self.text.frame.size.height +
                                                self.text.frame.origin.y + 20,
                                                TEXTFIELD_WIDTH,
                                                TEXTFIELD_HEIGHT);
        [self.noPictureButton addTarget:self
                                 action:@selector(noPictureButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.navBar];
        [self.view addSubview:self.text];
        [self.view addSubview:self.noPictureButton];
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
