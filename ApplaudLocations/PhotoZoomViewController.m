//
//  PhotoZoomViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/2/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PhotoZoomViewController.h"

@interface PhotoZoomViewController ()

@end

@implementation PhotoZoomViewController

- (id)initWithPhoto:(BusinessPhoto *)photo;
{
    if (self = [super init]) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        _navBar.barStyle = UIBarStyleBlackTranslucent;
        _photo = photo;
        self.hidesBottomBarWhenPushed = YES;
        self.view.backgroundColor = [UIColor blackColor];
        // Subtract some height from the screen's size for the navbar
        // and tabbar
        self.wantsFullScreenLayout = YES;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     320,
                                                                     480)];
        self.scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.contentSize = CGSizeMake(320, 460);
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   320, 480)];
        self.imageView.backgroundColor = [UIColor blackColor];
        [_imageView setImageWithURL:self.photo.imageURL
                   placeholderImage:nil
                            success:^(UIImage *image) {
                                self.imageView.frame = CGRectMake(0,
                                                                  (480.0 - image.size.height)/2,
                                                                  image.size.width,
                                                                  image.size.height);
                            }
                            failure:nil];
        [_scrollView addSubview:_imageView];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]
                                                    initWithImage:[UIImage imageNamed:@"white_comments.png"]
                                                    style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(commentButtonPressed)]];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]
                                                   initWithTitle:@"Back"
                                                   style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(backButtonPressed)]];
        [self.navBar pushNavigationItem:self.navigationItem animated:NO];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tapped)];
        [self.scrollView addGestureRecognizer:tap];
        [self.view addSubview:self.navBar];
    }
    return self;
}

/*-(void)setNavigationController:(UINavigationController *)navigationController {
    _navigationController = navigationController;
    _navigationController.navigationBarHidden = YES;
}*/

-(void)tapped {
    NSLog(@"SIZE %f %f", self.imageView.image.size.width, self.imageView.image.size.height);
    [UIView animateWithDuration:0.4 animations:^(void) {
        if(self.navBar.alpha == 0.0) {
            self.navBar.alpha = 1.0;
        }
        else {
            self.navBar.alpha = 0.0;
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
#pragma mark UIScrollView delegate methods

/*-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect newFrame = CGRectMake((self.view.frame.size.width -
                                  scrollView.zoomScale*self.imageView.image.size.width)/2,
                                 (self.view.frame.size.height -
                                  scrollView.zoomScale*self.imageView.image.size.height)/2,
                                 self.imageView.image.size.width*scrollView.zoomScale,
                                 self.imageView.image.size.height*scrollView.zoomScale);
    self.imageView.frame = newFrame;
}*/

/*-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}*/

#pragma mark -
#pragma mark Other methods

-(void)commentButtonPressed {
    PhotoCommentViewController *pcvc = [[PhotoCommentViewController alloc]
                                        initWithPhoto:self.photo];
    pcvc.appDelegate = self.appDelegate;
    [self presentViewController:pcvc animated:YES completion:nil];
}

-(void)backButtonPressed {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
