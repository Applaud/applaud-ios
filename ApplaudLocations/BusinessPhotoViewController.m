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
                                                                         self.view.frame.size.height)];
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
        self.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
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
#pragma mark UINavigationController delegate methods

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
#pragma mark UIImagePickerController delegate methods
// Called when the user has taken the photo. We can then send it off to the server.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    [[[UIAlertView alloc] initWithTitle:@"Thanks!"
                                message:@"What a great photo."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [ConnectionManager postPhoto:[[image normalizedImage] resizedImage]
                      withParams:@{@"business_id": @(self.appDelegate.currentBusiness.business_id),
                                   @"tags": @"[]"}
                        callback:^(NSHTTPURLResponse *r, NSData *d) {
                            [self getPhotos];
                        }
                           toURL:PHOTO_URL];
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
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    for(NSDictionary *photoDict in [photoData objectForKey:@"photos"]) {
        BusinessPhoto *photo = [[BusinessPhoto alloc] initWithImage:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, photoDict[@"image"]]]
                                                               tags:photoDict[@"tags"]
                                                            upvotes:[photoDict[@"votes"] intValue]
                                                           business:[photoDict[@"business"] intValue]
                                                        uploaded_by:photoDict[@"uploaded_by"]
                                                             active:[photoDict[@"active"] boolValue]
                                                           photo_id:[photoDict[@"id"] intValue]
                                                       thumbnailURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, photoDict[@"thumbnail"]]]
                                                        dateCreated:[format dateFromString:photoDict[@"date_created"]]];
        [self.businessPhotos addObject:photo];
    }
    [self.businessPhotos sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        BusinessPhoto *p1 = (BusinessPhoto *)obj1;
        BusinessPhoto *p2 = (BusinessPhoto *)obj2;
//        return [p2.dateCreated compare:p1.dateCreated];
        if(p1.photo_id == p2.photo_id)
            return NSOrderedSame;
        else if(p1.photo_id < p2.photo_id)
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    [self addPhotos];
}

-(void)addPhotos {
    CGFloat currentHeight = -80.0;
    int currentColumn = 0; // Which column this photo is in (0 to PHOTOS_PER_LINE)
    int tagnum = 0; // which index each button corresponds to in the array
    for(BusinessPhoto *photo in self.businessPhotos) {
        NSLog(@"DATE %@", photo.dateCreated);
        if(!currentColumn) {
            currentHeight += PHOTO_SIZE;
            self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                                     currentHeight + PHOTO_SIZE);
        }
        NSLog(@"CURRENT HEIGHT %f", currentHeight);
        UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(PHOTO_SIZE*currentColumn,
                                                                           currentHeight,
                                                                           PHOTO_SIZE,
                                                                           PHOTO_SIZE)];
        imageButton.tag = tagnum++;
        imageButton.imageView.frame = CGRectMake(0, 0,
                                                 PHOTO_SIZE,
                                                 PHOTO_SIZE);
//        NSArray *filenameParts = [photo.imageURL.absoluteString componentsSeparatedByString:@"."];
//        NSString *thumbnailURL = [NSString stringWithFormat:@"%@-thumbnail-%@", filenameParts[0], filenameParts[1]];
        NSLog(@"Image URL is: %@", photo.thumbnailURL.absoluteString);
        [imageButton setImageWithURL:photo.thumbnailURL
                    placeholderImage:nil
                             success:^(UIImage *image) {
                                 
                             }
                             failure:^(NSError *error) {
                             }];
        [imageButton addTarget:self
                        action:@selector(imageButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:imageButton];
        currentColumn = ++currentColumn % PHOTOS_PER_LINE;
    }
}

-(void)imageButtonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    PhotoZoomViewController *pzvc = [[PhotoZoomViewController alloc]
                                     initWithPhotos:self.businessPhotos
                                     index:button.tag];
    pzvc.appDelegate = self.appDelegate;
    pzvc.navigationController = self.navigationController;
    [self presentViewController:pzvc
                       animated:YES
                     completion:nil];
}

// Called when the user presses the camera button. Pretty straightforward.
- (void)cameraButtonPressed {
    [self presentViewController:self.imagePicker
                       animated:YES
                     completion:nil];
}
@end
