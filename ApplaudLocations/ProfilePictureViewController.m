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
            self.imagePicker.showsCameraControls = NO;
            self.imagePicker.cameraOverlayView = [self makeOverlayView];
            self.imagePicker.allowsEditing = NO;
        }
        self.text = [[UILabel alloc] init];
        self.text.text = @"Take your profile picture.";
        self.text.font = [UIFont systemFontOfSize:14.0f];
        self.text.lineBreakMode = UILineBreakModeWordWrap;
        self.text.numberOfLines = 0;
        self.text.frame = CGRectMake(10, 106, TEXTFIELD_WIDTH, 40);
        self.text.backgroundColor = [UIColor clearColor];
        self.noPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.noPictureButton.frame = CGRectMake(10, 150,
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

-(UIView *)makeOverlayView {
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    overlay.exclusiveTouch = YES;
    overlay.backgroundColor = [UIColor clearColor];
    
    UIView *topBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    topBlack.backgroundColor = [UIColor blackColor];
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    topBar.backgroundColor = [UIColor blackColor];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0].CGColor;
    bottomBorder.borderWidth = 1.0;
    bottomBorder.frame = CGRectMake(0, topBar.frame.size.height, 320, 1);
    [topBar.layer addSublayer:bottomBorder];
        
    CAGradientLayer *topBarLayer = [CAGradientLayer layer];
    topBarLayer.frame = topBar.layer.bounds;
    topBarLayer.colors = @[(id)[UIColor colorWithRed:.3333 green:.3333 blue:.3333 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.3333 green:.3333 blue:.3333 alpha:0.0].CGColor];
    topBarLayer.locations = @[@0.0f, @1.0f];
    
    [topBar.layer insertSublayer:topBarLayer atIndex:0];
    
    
    UIView *bottomBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 400, 320, 80)];
    bottomBlack.backgroundColor = [UIColor blackColor];
    
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0,436,320,44)];
        
    CAGradientLayer *bottomBarLayer = [CAGradientLayer layer];
    bottomBarLayer.frame = bottomBar.layer.bounds;
    bottomBarLayer.colors = @[(id)[UIColor colorWithRed:.9529 green:.9529 blue:.9333 alpha:1.0].CGColor, (id)[UIColor colorWithRed:.5058 green:.5137 blue:.5372 alpha:1.0].CGColor];
    bottomBarLayer.locations = @[@0.0f, @1.0f];
    
    [bottomBar.layer insertSublayer:bottomBarLayer atIndex:0];
    
    UIImage *flipButtonImage = [UIImage imageNamed:@"flipCamera"];
    UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flipButton setBackgroundImage:flipButtonImage forState:UIControlStateNormal];
    flipButton.frame = CGRectMake(124, 5, 72, 36);
    [flipButton addTarget:self action:@selector(flipButtonPressed)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *takePictureButtonImage = [UIImage imageNamed:@"camera"];
    UIButton *takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePictureButton setBackgroundImage:takePictureButtonImage forState:UIControlStateNormal];
    takePictureButton.frame = CGRectMake(115, 436, 110, 46);
    [takePictureButton addTarget:self action:@selector(takePictureButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:12];
    cancelButton.titleLabel.textColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.layer.cornerRadius = 3;
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.borderColor = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0].CGColor;
    cancelButton.frame = CGRectMake(260, 443, 50, 30);
    [cancelButton addTarget:self action:@selector(cancelButtonPressed)
           forControlEvents:UIControlEventTouchUpInside];
    
    [overlay addSubview:topBlack];
    [overlay addSubview:topBar];
    [overlay addSubview:bottomBlack];
    [overlay addSubview:bottomBar];
    [overlay addSubview:flipButton];
    [overlay addSubview:takePictureButton];
    [overlay addSubview:cancelButton];
    return overlay;
}

-(void)cancelButtonPressed {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)takePictureButtonPressed {
    [self.imagePicker takePicture];
}

-(void)flipButtonPressed {
    if(self.imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    else {
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
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
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = [[image normalizedImage] resizedImage];
    [ConnectionManager authenticateWithUsername:self.username password:self.password];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Other methods

-(void)noPictureButtonPressed {
    // We don't want to post the picture if we don't have a picture.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
