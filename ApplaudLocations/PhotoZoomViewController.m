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

- (id)initWithPhotos:(NSMutableArray *)photos index:(int)index;
{
    if (self = [super init]) {
        _photos = photos;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        _navBar.barStyle = UIBarStyleBlackTranslucent;
        self.hidesBottomBarWhenPushed = YES;
        self.view.backgroundColor = [UIColor blackColor];
        self.wantsFullScreenLayout = YES;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        self.scrollView.scrollEnabled = NO;
        self.scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.backgroundColor = [UIColor blackColor];
        CGFloat scrollWidth = self.photos.count*320 + (self.photos.count-1)*PHOTO_BORDER;
        _scrollView.contentSize = CGSizeMake(scrollWidth, 480);
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
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
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(swiped:)];
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(swiped:)];
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.scrollView addGestureRecognizer:tap];
        [self.scrollView addGestureRecognizer:rightSwipe];
        [self.scrollView addGestureRecognizer:leftSwipe];
        [self.view addSubview:self.navBar];
        [self addBusinessPhotos];
        [self setIndex:index animated:NO];
    }
    return self;
}

-(void)setIndex:(int)index animated:(BOOL)animated {
    if(index < 0) {
        _index = 0;
        return;
    }
    if(index >= self.photos.count) {
        _index = self.photos.count-1;
        return;
    }
    _index = index;
    CGPoint newOffset = CGPointMake((320+PHOTO_BORDER)*index, 0);
    [self.scrollView setContentOffset:newOffset animated:animated];
}

-(void)addBusinessPhotos {
    int i;
    for(i = 0; i < self.photos.count; i++) {
        [self addPhoto:self.photos[i] index:i];
    }
}

-(void)addPhoto:(BusinessPhoto *)photo index:(int)index {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((320+PHOTO_BORDER)*index,
                                                                           0,
                                                                           320,
                                                                           480)];
    imageView.backgroundColor = [UIColor blackColor];
    [imageView setImageWithURL:photo.imageURL
              placeholderImage:nil
                       success:^(UIImage *image) {
                           CGRect oldFrame = imageView.frame;
                           imageView.frame = CGRectMake(oldFrame.origin.x,
                                                        (480-image.size.height)/2,
                                                        320,
                                                        image.size.height);
                       }
                       failure:nil];
    [self.scrollView addSubview:imageView];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width + PHOTO_BORDER + 320,
                                             480);
}

-(void)swiped:(UISwipeGestureRecognizer *)swipe {
    if(swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self setIndex:self.index + 1 animated:YES];
        NSLog(@"SWIPED LEFT");
    }
    else if(swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        [self setIndex:self.index - 1 animated:YES];
        NSLog(@"SWIPED RIGHT");
    }
}

-(void)tapped {
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
#pragma mark Other methods

-(void)commentButtonPressed {
    PhotoCommentViewController *pcvc = [[PhotoCommentViewController alloc]
                                        initWithPhoto:self.photos[self.index]];
    pcvc.appDelegate = self.appDelegate;
    [self presentViewController:pcvc animated:YES completion:nil];
}

-(void)backButtonPressed {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
