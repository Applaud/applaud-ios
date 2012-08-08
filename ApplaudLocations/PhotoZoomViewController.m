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
        _photo = photo;
        self.view.backgroundColor = [UIColor blackColor];
        // Subtract some height from the screen's size for the navbar
        // and tabbar
        CGRect mainFrame = [[UIScreen mainScreen] applicationFrame];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(mainFrame.origin.x,
                                                                     mainFrame.origin.y + BUTTON_HEIGHT,
                                                                     mainFrame.size.width,
                                                                     mainFrame.size.height - 64 - 44)];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.contentSize = CGSizeMake(320, 436 - 44 - 64);
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)];
        [_imageView setImageWithURL:self.photo.imageURL
                   placeholderImage:[UIImage imageNamed:@"default.jpg"]
                            success:^(UIImage *image) {
                                self.imageView.frame = CGRectMake((self.view.frame.size.width-image.size.width)/2,
                                                                  (self.view.frame.size.height-image.size.height)/2,
                                                                  image.size.width,
                                                                  image.size.height);
                            }
                            failure:nil];
        [_scrollView addSubview:_imageView];
        self.upButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.upButton.frame = CGRectMake(self.view.frame.size.width/2 - BUTTON_WIDTH,
                                    BUTTON_MARGIN,
                                    BUTTON_WIDTH,
                                    BUTTON_HEIGHT);
        [self.upButton setTitle:@"Up" forState:UIControlStateNormal];
        [self.upButton addTarget:self action:@selector(upButtonPressed)
           forControlEvents:UIControlEventTouchUpInside];
        self.downButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.downButton.frame = CGRectMake(self.view.frame.size.width/2,
                                      BUTTON_MARGIN,
                                      BUTTON_WIDTH,
                                      BUTTON_HEIGHT);
        [self.downButton setTitle:@"Down" forState:UIControlStateNormal];
        [self.downButton addTarget:self action:@selector(downButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
        [self checkCanVoteOnPhoto:self.photo.photo_id];
        self.votes = [[UILabel alloc] initWithFrame:CGRectMake(BUTTON_MARGIN,
                                                               BUTTON_MARGIN,
                                                               BUTTON_HEIGHT,
                                                               BUTTON_HEIGHT)];
        self.votes.text = [NSString stringWithFormat:@"%d", self.photo.upvotes -
                           self.photo.downvotes];
        self.votes.textColor = [UIColor whiteColor];
        self.votes.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.votes];
        self.scrollView.maximumZoomScale = 1.5;
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]
                                                    initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                    target:self
                                                    action:@selector(commentButtonPressed)]];
    }
    return self;
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
#pragma Button events

-(void)upButtonPressed {
    [self sendPhotoVote:@"up"];
}

-(void)downButtonPressed {
    [self sendPhotoVote:@"down"];
}

/*
 * vote is either @"up" or @"down"
 */
-(void)sendPhotoVote:(NSString *)vote {
    NSDictionary *params = @{@"photo_id": @(self.photo.photo_id),
                             @"vote": vote};
    [ConnectionManager serverRequest:@"POST" withParams:params
                                 url:PHOTO_VOTE_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                NSString *response = [[NSString alloc]
                                                      initWithData:d
                                                      encoding:NSUTF8StringEncoding];
                                if([response isEqualToString:@""]) {
                                    if([vote isEqualToString:@"up"]) {
                                        self.votes.text = [NSString stringWithFormat:@"%d",
                                                           [self.votes.text intValue] + 1];
                                    }
                                    else {
                                        self.votes.text = [NSString stringWithFormat:@"%d",
                                                           [self.votes.text intValue] - 1];
                                    }
                                    [self.upButton removeFromSuperview];
                                    [self.downButton removeFromSuperview];
                                }
                            }];
}

-(void)checkCanVoteOnPhoto:(int)photo {
    NSDictionary *params = @{@"photo": @(photo)};
    [ConnectionManager serverRequest:@"GET" withParams:params
                                 url:CHECK_VOTE_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                NSString *response = [[NSString alloc]
                                                      initWithData:d
                                                      encoding:NSUTF8StringEncoding];
                                if([response isEqualToString:@""]) {
                                    [self.view addSubview:self.upButton];
                                    [self.view addSubview:self.downButton];
                                }
                            }];
}

#pragma mark -
#pragma UIScrollView delegate methods

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect newFrame = CGRectMake((self.view.frame.size.width -
                                  scrollView.zoomScale*self.imageView.image.size.width)/2,
                                 (self.view.frame.size.height -
                                  scrollView.zoomScale*self.imageView.image.size.height)/2,
                                 self.imageView.image.size.width*scrollView.zoomScale,
                                 self.imageView.image.size.height*scrollView.zoomScale);
    self.imageView.frame = newFrame;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark -
#pragma Other methods

-(void)commentButtonPressed {
    PhotoCommentViewController *pcvc = [[PhotoCommentViewController alloc]
                                        initWithPhoto:self.photo];
    pcvc.appDelegate = self.appDelegate;
    [self presentViewController:pcvc animated:YES completion:nil];
}

@end
