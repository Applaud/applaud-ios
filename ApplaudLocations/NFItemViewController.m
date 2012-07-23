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

    // Set the image
    self.image.image = self.item.image;

    // Format and set the date label
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = NSDateFormatterLongStyle;
    self.dateLabel.text = [format stringFromDate:self.item.date];
    
    // Set and size the title label
    self.titleLabel.text = self.item.title;
    CGSize titleTextContraint = CGSizeMake(self.view.frame.size.width - 2*VIEW_PADDING, 
                                           300);
    CGRect titleTextFrame = self.titleLabel.frame;
    titleTextFrame.size.height = [self.item.title sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]
                                             constrainedToSize:titleTextContraint lineBreakMode:UILineBreakModeWordWrap].height + 50;
    self.titleLabel.frame = titleTextFrame;
    
    // Set the subtitle label
    self.subtitleLabel.text = self.item.subtitle;
    
    // Adjust frame of the body text according to its content
    self.bodyText.text = self.item.body;
    CGSize bodyTextContraint = CGSizeMake(self.view.frame.size.width - 2*VIEW_PADDING,
                                          2000);
    CGRect bodyTextFrame = self.bodyText.frame;
    bodyTextFrame.size.height = [self.item.body sizeWithFont:[UIFont systemFontOfSize:12.0f] 
                                           constrainedToSize:bodyTextContraint 
                                               lineBreakMode:UILineBreakModeWordWrap].height + 50;
    [self.bodyText setFrame:bodyTextFrame];
    
    // Set the contentsize of the scrollview
    [(UIScrollView*)self.view setContentSize:CGSizeMake(self.view.frame.size.width, 300 + bodyTextFrame.size.height)];
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
