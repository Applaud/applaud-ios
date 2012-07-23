//
//  BusinessPhotoViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/23/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "BusinessPhotoViewController.h"
#import "AppDelegate.h"

@interface BusinessPhotoViewController ()
@end

@implementation BusinessPhotoViewController
@synthesize navigationController = _navigationController;
@synthesize appDelegate = _appDelegate;
@synthesize imagePicker = _imagePicker;
@synthesize cameraButton = _cameraButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.delegate = self;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setCameraButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma UINavigationController delegate methods

-(void)navigationController:(UINavigationController *)navigationController
      didShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated {
    // I don't know why this is necessary. Let's do nothing!
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated {
    // I don't know why this is necessary. Let's do nothing!
}

#pragma mark -
#pragma UIImagePickerController delegate methods
// Called when the user has taken the photo. We can then send it off to the server.
-(void)imagePickerController:(UIImagePickerController *)picker
       didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo {
    [[[UIAlertView alloc] initWithTitle:@"Thanks!"
                                message:@"What a great photo."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    UIImage *userImage = [editingInfo objectForKey:@"UIImagePickerControllerOriginalImage"];
    // Get the JPEG data for the image. This is really high-quality
    // now -- might have to scale it down if network stuff is a problem.
    NSData *imageData = UIImageJPEGRepresentation(userImage, 1.0);
    [ConnectionManager serverRequest:@"POST"
                            withData:imageData
                                 url:PHOTO_URL];
}
// Called when the user presses the cancel button.
// We'll do nothing for now.
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

// Called when the user presses the camera button. Pretty straightforward.
- (IBAction)cameraButtonPressed {
    [self presentViewController:self.imagePicker
                       animated:YES
                     completion:nil];
}
@end
