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
@synthesize dismissButton = _dismissButton;

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
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"hh:mm eeee dd LLLL yyyy"]; // see the documentation on NSDateFormatter to make sense of the format string
    self.titleLabel.text = self.item.title;
    self.bodyText.text = self.item.body;
    self.subtitleLabel.text = self.item.subtitle;
    self.dateLabel.text = [format stringFromDate:self.item.date];
}

- (void)viewDidUnload
{
    [self setBodyText:nil];
    [self setSubtitleLabel:nil];
    [self setDateLabel:nil];
    [self setDismissButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 * dismisses the current item detail, and deselects the corresponding row in the table.
 *
 * kinda gross way of finding the right row to deselect; oh well.
 */
- (IBAction)buttonPressed:(id)sender {
    UITabBarController *presenting = (UITabBarController *)self.presentingViewController;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    UITableView *tableView = [[presenting.viewControllers objectAtIndex:3] tableView];
    NSIndexPath *path = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:path animated:YES];
}
@end
