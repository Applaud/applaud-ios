//
//  ErrorViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 7/28/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "ErrorViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

#define VIEW_PADDING 10.f
#define CONTENT_PADDING 10.0f
#define VIEW_ELEMENT_PADDING 20.0f
#define TITLE_SIZE 18.0f
#define BODY_SIZE 12.0f

@interface ErrorViewController ()

@end

@implementation ErrorViewController

- (id)init {
    self = [super init];
    if ( self ) {
        self.errorTitle = [[UILabel alloc] init];
        self.errorBody = [[UILabel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Background image
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    self.backgroundView.contentMode = UIViewContentModeBottom;
    [self.view addSubview:self.backgroundView];
    
    // Error text
    extern int error_code;

    switch ( error_code ) {
        case ERROR_BAD_LOGIN:
            self.errorTitle.text = tERROR_BAD_LOGIN;
            self.errorBody.text = bERROR_BAD_LOGIN;
            break;
        case ERROR_NO_CONNECTION:
            self.errorTitle.text = tERROR_NO_CONNECTION;
            self.errorBody.text = bERROR_NO_CONNECTION;
            break;
        case ERROR_SERVER_ERROR:
            self.errorTitle.text = tERROR_SERVER_ERROR;
            self.errorBody.text = bERROR_SERVER_ERROR;
            break;
        case ERROR_NO_LOCATION:
            self.errorTitle.text = tERROR_NO_LOCATION;
            self.errorBody.text = bERROR_NO_LOCATION;
            break;
        default:
            self.errorTitle.text = @"Unknown error.";
            self.errorBody.text = @"You do not see me!";
    }
    
    // Reset the error code
    error_code = 0;
    
    NSLog(@"%@ : %@",self.errorTitle.text, self.errorBody.text);
    
    self.errorTitle.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
    self.errorTitle.numberOfLines = 0;
    self.errorTitle.lineBreakMode = UILineBreakModeWordWrap;
    CGSize titleSize = CGSizeMake( self.view.frame.size.width - 2*(VIEW_PADDING + CONTENT_PADDING),
                                  [self.errorTitle.text sizeWithFont:[UIFont systemFontOfSize:TITLE_SIZE]
                                                   constrainedToSize:CGSizeMake( self.view.frame.size.width - 2*(VIEW_PADDING + CONTENT_PADDING), 400)
                                                       lineBreakMode:UILineBreakModeWordWrap].height );
    self.errorTitle.frame = CGRectMake(CONTENT_PADDING,
                                       CONTENT_PADDING,
                                       self.view.frame.size.width - 2*(VIEW_PADDING + CONTENT_PADDING),
                                       titleSize.height);
    UIView *titleWrapper = [[UIView alloc] initWithFrame:CGRectMake(VIEW_PADDING,
                                                                    VIEW_PADDING,
                                                                    self.view.frame.size.width - 2*VIEW_PADDING,
                                                                    titleSize.height + 2*CONTENT_PADDING)];
    titleWrapper.backgroundColor = [UIColor whiteColor];
    titleWrapper.layer.cornerRadius = 3.0f;
    titleWrapper.layer.masksToBounds = YES;

    [titleWrapper addSubview:self.errorTitle];
    [self.view addSubview:titleWrapper];
    
    CGSize bodySize = CGSizeMake( self.view.frame.size.width - 2*(VIEW_PADDING + CONTENT_PADDING),
                                  [self.errorBody.text sizeWithFont:[UIFont systemFontOfSize:BODY_SIZE]
                                                  constrainedToSize:CGSizeMake( self.view.frame.size.width - 2*(VIEW_PADDING + CONTENT_PADDING), 400)
                                                      lineBreakMode:UILineBreakModeWordWrap].height );
    self.errorBody.frame = CGRectMake(CONTENT_PADDING,
                                      CONTENT_PADDING,
                                      self.view.frame.size.width - 2*(VIEW_PADDING + CONTENT_PADDING),
                                      bodySize.height);
    self.errorBody.lineBreakMode = UILineBreakModeWordWrap;
    self.errorBody.numberOfLines = 0;
    UIView *bodyWrapper = [[UIView alloc] initWithFrame:CGRectMake(VIEW_PADDING,
                                                                   titleWrapper.frame.origin.y + titleWrapper.frame.size.height + VIEW_ELEMENT_PADDING,
                                                                   self.view.frame.size.width - 2*VIEW_PADDING,
                                                                   bodySize.height + 2*CONTENT_PADDING)];
    bodyWrapper.backgroundColor = [UIColor whiteColor];
    bodyWrapper.layer.cornerRadius = 3.0f;
    bodyWrapper.layer.masksToBounds = YES;
    self.errorBody.font = [UIFont systemFontOfSize:BODY_SIZE];
    [bodyWrapper addSubview:self.errorBody];
    [self.view addSubview:bodyWrapper];
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

/*
 * Gross and hacky!
 */
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.appDelegate application:nil didFinishLaunchingWithOptions:nil];
}

@end
