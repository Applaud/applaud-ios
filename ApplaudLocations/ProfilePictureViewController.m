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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:@"LOGIN_SUCCESS"
                                                   object:nil];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0,
                                                                        320, 44)];
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                      target:self
                                                                                      action:@selector(cameraButtonPressed)];
        self.navigationItem.rightBarButtonItem = cameraButton;
        [self.navBar pushNavigationItem:self.navigationItem animated:NO];
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerCameraCaptureModePhoto]) {
            self.imagePicker.sourceType = UIImagePickerControllerCameraCaptureModePhoto;
            self.imagePicker.allowsEditing = NO;
        }
        [self.view addSubview:self.navBar];
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

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [ConnectionManager authenticateWithUsername:self.username password:self.password];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Other methods

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
