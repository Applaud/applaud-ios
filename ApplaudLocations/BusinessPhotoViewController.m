//
//  BusinessPhotoViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 7/23/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "BusinessPhotoViewController.h"
#import "AppDelegate.h"

#define BOUNDARY @"2sdf2MASTERsd23TRASH982cca"

@interface BusinessPhotoViewController ()
@end

@implementation BusinessPhotoViewController
@synthesize navigationController = _navigationController;
@synthesize appDelegate = _appDelegate;
@synthesize imagePicker = _imagePicker;
@synthesize cameraButton = _cameraButton;
@synthesize businessPhotos = _businessPhotos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.delegate = self;
            self.imagePicker.allowsEditing = NO;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(notificationReceived:)
                                                   name:@"BUSINESS_SET"
                                                 object:nil];
    }
    return self;
}

-(void)notificationReceived:(NSNotification *)notification {
    if([notification.name isEqualToString:@"BUSINESS_SET"]) {
        [self getPhotos];
    }
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
    [self postPhotoData:image];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}
// Called when the user presses the cancel button.
// We'll do nothing for now.
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma Other stuff

-(void)getPhotos {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.appDelegate.currentBusiness.business_id], @"id", nil];
    [ConnectionManager serverRequest:@"GET"
                          withParams:params
                                 url:GET_PHOTO_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                [self handlePhotoData:[NSJSONSerialization JSONObjectWithData:d
                                                                                      options:0
                                                                                        error:nil]];
                            }];
}

// Do stuff with the photos from the server.
-(void)handlePhotoData:(NSDictionary *)photoData {
    for(NSDictionary *photoDict in [photoData objectForKey:@"photos"]) {
        BusinessPhoto *photo = [[BusinessPhoto alloc] initWithImage:nil
                                                               tags:photoDict[@"tags"]
                                                            upvotes:[photoDict[@"upvotes"] intValue]
                                                          downvotes:[photoDict[@"downvotes"] intValue]
                                                           business:[photoDict[@"business_id"] intValue]
                                                        uploaded_by:photoDict[@"uploaded_by"]
                                                             active:[photoDict[@"active"] boolValue]];
        [self.businessPhotos addObject:photo];
    }
}

// Send an image to the server.
-(void)postPhotoData:(UIImage *)photo {
    // The body of the HTTP request.
    NSMutableData *body = [[NSMutableData alloc] init];
    // Boundary data strings.
    NSData *start = [[NSString stringWithFormat:@"--%@\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding];
    // These are a dictionary, so we can use a loop.
    NSDictionary *params = [[NSDictionary alloc]
                            initWithObjectsAndKeys:[NSNumber numberWithInt:self.appDelegate.currentBusiness.business_id],
                            @"business_id",
                            @"[]", // being lazy -- change this to JSON!
                            @"tags",
                            nil];
    for (NSString *param in params) {
        [body appendData:start];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        // [body appendData:[@"Content-Type: text/plain; charset=utf-8\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // Add the image.
    [body appendData:start];
    [body appendData:[@"Content-Disposition: file; name=\"image\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // [body appendData:[@"Content-Transfer-Encoding: binary" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImageJPEGRepresentation(photo, .1)];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
 
    // Now make the request.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.timeoutInterval = 10;
    request.HTTPMethod = @"POST";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDARY];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = body;
    request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, PHOTO_URL]];
    [ConnectionManager getCSRFTokenFromURL:PHOTO_URL withCallback:^(NSHTTPURLResponse *response, NSString *csrf, NSError *error) {
        [request addValue:csrf forHTTPHeaderField:@"X-CSRFToken"];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {        }];
    }];
}

// Called when the user presses the camera button. Pretty straightforward.
- (IBAction)cameraButtonPressed {
    [self presentViewController:self.imagePicker
                       animated:YES
                     completion:nil];
}
@end
