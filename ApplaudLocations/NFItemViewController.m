//
//  NFItemViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NFItemViewController.h"

@interface NFItemViewController ()

@end

@implementation NFItemViewController

@synthesize item = _item;
@synthesize titleLabel = _titleLabel;
@synthesize bodyText = _bodyText;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize dateLabel = _dateLabel;
@synthesize image = _image;

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

    // Our XIB assumes that we have an image. The x-coordinate of the origin needs to be adjusted
    // only if there is no image.
    CGRect titleTextFrame;
    if ( self.item.image ) {
        // Set the image
        self.image.image = self.item.image;
        self.image.frame = CGRectMake(VIEW_PADDING,
                                      VIEW_PADDING + NAVIGATION_GAP, 
                                      IMAGE_SIZE, 
                                      IMAGE_SIZE);
        
        // Rect for title
        CGSize titleTextContraint = CGSizeMake(self.view.frame.size.width - 2*VIEW_PADDING - IMAGE_SIZE - ELEMENT_PADDING, 
                                               300);
        titleTextFrame = self.titleLabel.frame;
        titleTextFrame.size.height = [self.item.title sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]
                                                 constrainedToSize:titleTextContraint
                                                     lineBreakMode:UILineBreakModeWordWrap].height;
        titleTextFrame.origin.y = VIEW_PADDING;
        self.titleLabel.frame = titleTextFrame;
    } 
    // Adjusting x-coords of frames here
    else {
        // Size and position the title label
        CGSize titleTextContraint = CGSizeMake(self.view.frame.size.width - 2*VIEW_PADDING, 
                                               300);
        titleTextFrame = self.titleLabel.frame;
        titleTextFrame.size.height = [self.item.title sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]
                                                 constrainedToSize:titleTextContraint lineBreakMode:UILineBreakModeWordWrap].height;
        titleTextFrame.origin.x = VIEW_PADDING;
        titleTextFrame.origin.y = VIEW_PADDING;
        titleTextFrame.size.width = self.view.frame.size.width - 2*VIEW_PADDING;
        self.titleLabel.frame = titleTextFrame;
    }
    
    // Set the title label
    self.titleLabel.text = self.item.title;

    // Size and position the subtitle label
    CGRect subtitleTextFrame = self.subtitleLabel.frame;
    subtitleTextFrame.origin.y = VIEW_PADDING + titleTextFrame.size.height + ELEMENT_PADDING;
    subtitleTextFrame.origin.x = VIEW_PADDING;
    subtitleTextFrame.size.width = self.view.frame.size.width - 2*VIEW_PADDING;
    self.subtitleLabel.frame = subtitleTextFrame;
    
    // Set the subtitle label
    self.subtitleLabel.text = self.item.subtitle;
    
    // Format, set, and position the date label
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = NSDateFormatterLongStyle;
    self.dateLabel.text = [format stringFromDate:self.item.date];
    CGRect dateTextFrame = self.dateLabel.frame;
    dateTextFrame.origin.y = subtitleTextFrame.origin.y + subtitleTextFrame.size.height + ELEMENT_PADDING;
    dateTextFrame.origin.x = VIEW_PADDING;
    self.dateLabel.frame = dateTextFrame;
    
    // Format, set, and position the body text
    self.bodyText.text = self.item.body;
    CGSize bodyTextContraint = CGSizeMake(self.view.frame.size.width - 2*VIEW_PADDING,
                                          2000);
    CGRect bodyTextFrame = self.bodyText.frame;
    bodyTextFrame.size.height = [self.item.body sizeWithFont:[UIFont systemFontOfSize:12.0f] 
                                           constrainedToSize:bodyTextContraint 
                                               lineBreakMode:UILineBreakModeWordWrap].height + 50;
    bodyTextFrame.origin.y = dateTextFrame.origin.y + dateTextFrame.size.height + ELEMENT_PADDING;
    bodyTextFrame.origin.x = VIEW_PADDING;
    [self.bodyText setFrame:bodyTextFrame];
    
    // Set the contentsize of the scrollview
    [(UIScrollView*)self.view setContentSize:CGSizeMake(self.view.frame.size.width, 
                                                        2*VIEW_PADDING 
                                                        + titleTextFrame.size.height
                                                        + subtitleTextFrame.size.height
                                                        + dateTextFrame.size.height
                                                        + bodyTextFrame.size.height
                                                        + 3*ELEMENT_PADDING)];
}

- (void)viewDidUnload
{
    [self setBodyText:nil];
    [self setSubtitleLabel:nil];
    [self setDateLabel:nil];
    [self setImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 * Deselects the corresponding row in the NFViewController when the back button is pressed.
 */
- (void)viewWillDisappear:(BOOL)animated {
    UINavigationController *parent = (UINavigationController *)self.parentViewController;
    UITableView *tableView = [[parent.viewControllers objectAtIndex:0] tableView];
    NSIndexPath *path = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:path animated:YES];
}
@end
