//
//  NFItemViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFItemViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"

#define VIEW_PADDING 10.0f
#define IMAGE_SIZE 130.0f
#define ELEMENT_PADDING 10.0f
#define NAVIGATION_GAP 42.0f    // Gap left for the navigationBar of the UINavigationController

@implementation NFItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setItem:(NFItem *)item {
    _item = item;
}

/*
 * Set up text for the detail view.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.image setImageWithURL:self.item.imageURL
                        success:^(UIImage *img) {
                            [self loadViewWithImage:img];
                        } failure:^(NSError *error) {
                            [self loadViewWithImage:nil];
                        }];
    
}

- (void)loadViewWithImage:(UIImage *)img {
    // Take care of dynamic layout
    CGRect titleTextFrame;
    if ( img ) {
        // Set the image
        float scaleFactor = img.size.width * img.scale / IMAGE_SIZE;
        self.image.image = [UIImage imageWithCGImage:img.CGImage
                                               scale:scaleFactor
                                         orientation:UIImageOrientationUp];
        [self.image sizeToFit];
        CGRect imageRect = self.image.frame;
        imageRect.origin.x = VIEW_PADDING;
        imageRect.origin.y = VIEW_PADDING;
        self.image.frame = imageRect;
        
        // Rect for title
        titleTextFrame = self.titleLabel.frame;
        titleTextFrame.origin.y = VIEW_PADDING;
        self.titleLabel.frame = titleTextFrame;
        
    }
    // Adjusting x-coords of frames here
    else {
        // Size and position the title label
        titleTextFrame = self.titleLabel.frame;
        titleTextFrame.origin.x = VIEW_PADDING;
        titleTextFrame.origin.y = VIEW_PADDING;
        titleTextFrame.size.width = self.view.frame.size.width - 2*VIEW_PADDING;
        self.titleLabel.frame = titleTextFrame;
        
    }
    
    // Set the title label
    self.titleLabel.text = self.item.title;
    [self.titleLabel sizeToFit];
    
    // Format, set, and position the date label
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = NSDateFormatterLongStyle;
    self.dateLabel.text = [format stringFromDate:self.item.date];
    CGRect dateTextFrame = self.dateLabel.frame;
    dateTextFrame.origin.y = titleTextFrame.origin.y + titleTextFrame.size.height + ELEMENT_PADDING;
    dateTextFrame.origin.x = VIEW_PADDING;
    self.dateLabel.frame = dateTextFrame;
    
    // Format, set, and position the body text
    self.bodyText.text = self.item.body;
    [self.bodyText sizeToFit];
    CGRect bodyTextFrame = self.bodyText.frame;
    bodyTextFrame.origin.y = dateTextFrame.origin.y + dateTextFrame.size.height + ELEMENT_PADDING;
    bodyTextFrame.origin.x = VIEW_PADDING;
    [self.bodyText setFrame:bodyTextFrame];
    
    // Set the contentsize of the scrollview
    [(UIScrollView*)self.view setContentSize:CGSizeMake(self.view.frame.size.width, 
                                                        2*VIEW_PADDING 
                                                        + titleTextFrame.size.height
                                                        + dateTextFrame.size.height
                                                        + bodyTextFrame.size.height
                                                        + 3*ELEMENT_PADDING)];

}

- (void)viewDidUnload
{
    [self setBodyText:nil];
    [self setDateLabel:nil];
    [self setImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

/*
 * Deselects the corresponding row in the NFViewController when the back button is pressed.
 */
- (void)viewWillDisappear:(BOOL)animated {
    UINavigationController *parent = (UINavigationController *)self.parentViewController;
    UITableView *tableView = [parent.viewControllers[0] tableView];
    NSIndexPath *path = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:path animated:YES];
}
@end
