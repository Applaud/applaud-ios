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

- (id) init
{
    self = [super init];
    if (self) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.delegate = self;
            self.imagePicker.allowsEditing = NO;
        }
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64,
                                                                         self.view.frame.size.width,
                                                                         PHOTO_MARGIN)];
        self.view = self.scrollView;
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
        self.navigationController.navigationBar.tintColor = self.appDelegate.currentBusiness.primaryColor;
        self.navigationItem.title = @"Photos";
    }
}

-(void)backButtonPressed {
    [self.appDelegate backButtonPressed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                           target:self
                                                                                           action:@selector(cameraButtonPressed)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonPressed)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
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
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self postPhotoData:image];
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
    self.businessPhotos = [[NSMutableArray alloc] init];
    for(NSDictionary *photoDict in [photoData objectForKey:@"photos"]) {
        BusinessPhoto *photo = [[BusinessPhoto alloc] initWithImage:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, photoDict[@"image"]]]
                                                               tags:photoDict[@"tags"]
                                                            upvotes:[photoDict[@"upvotes"] intValue]
                                                          downvotes:[photoDict[@"downvotes"] intValue]
                                                           business:[photoDict[@"business"] intValue]
                                                        uploaded_by:photoDict[@"uploaded_by"]
                                                             active:[photoDict[@"active"] boolValue]];
        [self.businessPhotos addObject:photo];
    }
    [self addPhotos];
}

-(void)addPhotos {
    CGFloat currentHeight = PHOTO_MARGIN;
    for(BusinessPhoto *photo in self.businessPhotos) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(PHOTO_PADDING,
                                                                       currentHeight,
                                                                       self.view.frame.size.width,
                                                                       2*PHOTO_PADDING + PHOTO_SIZE)];
        UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(PHOTO_PADDING,
                                                                           PHOTO_PADDING,
                                                                           PHOTO_SIZE,
                                                                           PHOTO_SIZE)];
        imageButton.imageView.frame = CGRectMake(0, 0,
                                                 PHOTO_SIZE - 2*PHOTO_PADDING,
                                                 PHOTO_SIZE - 2*PHOTO_PADDING);
        [imageButton setImageWithURL:photo.imageURL
                    placeholderImage:[UIImage imageNamed:@"blankPerson.jpg"]
                             success:^(UIImage *image) {
                                 
                             }
                             failure:nil];
        [imageButton addTarget:self
                        action:@selector(imageButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:imageButton];
        [self.view addSubview:contentView];
        currentHeight += contentView.frame.size.height + PHOTO_MARGIN;
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                                 currentHeight);
    }
}

-(void)imageButtonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    PhotoZoomViewController *pzvc = [[PhotoZoomViewController alloc] initWithImage:button.imageView.image];
    [self.navigationController pushViewController:pzvc animated:YES];
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
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // Add the image.
    [body appendData:start];
    [body appendData:[@"Content-Disposition: file; name=\"image\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImageJPEGRepresentation(photo, 1)];
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
                               completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {}];
    }];
}

// Called when the user presses the camera button. Pretty straightforward.
- (void)cameraButtonPressed {
    [self presentViewController:self.imagePicker
                       animated:YES
                     completion:nil];
}
@end
