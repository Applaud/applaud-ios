//
//  MinglePostViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MinglePostViewController.h"
#import "ThreadPost.h"
#import "MingleDisplayConstants.h"
#import "MinglePostCell.h"
#import "ConnectionManager.h"
#import "MingleListViewController.h"
#import "MingleThreadCell.h"

@interface MinglePostViewController ()

@end

@implementation MinglePostViewController

- (id)initWithStyle:(UITableViewStyle)style thread:(Thread *)thread
{
    self = [super initWithStyle:style];
    if (self) {
        _thread = thread;
        cellMap = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.thread.title;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 80, 20.0f)];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.delegate = self;
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(submitPost)];
    //UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitPost)];
    submitButton.tintColor = [UIColor grayColor];
    submitButton.title = @"Post";
    UIBarButtonItem *textItem = [[UIBarButtonItem alloc] initWithCustomView:self.textField];
    
    self.toolbarWidgets = [[NSMutableArray alloc] initWithObjects:textItem, submitButton, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set our toolbar items
    [self setToolbarItems:self.toolbarWidgets animated:YES];
    
    // Listen for keyboard to show
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [self.textField resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // section 0: title/thread info. section 1: posts
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( 0 == section )
        return 1;
    
    // Return the number of rows in the section.
    return MAX(1,self.threadPosts.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 ) {
        static NSString *ThreadTitleID = @"MinglePostsHeader";
        MingleThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:ThreadTitleID];
        if ( nil == cell ) {
            cell = [[MingleThreadCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:ThreadTitleID
                                                    thread:self.thread];
            cell.textLabel.text = self.thread.title;
        } else {
            [cell setThread:self.thread];
        }
        return cell;
    }
    
    // No posts in this thread yet
    if ( self.threadPosts.count < 1 ) {
        static NSString *CellIdentifier = @"MinglePostCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if ( nil == cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"No posts here yet!";
        }
        return cell;
    }
    
    NSString *cellKey = [NSString stringWithFormat:@"%d",[self.threadPosts[indexPath.row] threadpost_id]];
    MinglePostCell *cell = [cellMap objectForKey:cellKey];
    if ( nil == cell ) {
        // Build a cell for each posting
        cell = [[MinglePostCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellKey
                                          threadPost:self.threadPosts[indexPath.row]];
        cell.mpvc = self;
        [cellMap setObject:cell forKey:cellKey];
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set shape and color
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 7.0f;
    
    // Some nice visual FX
    cell.contentView.layer.shadowRadius = 5.0f;
    cell.contentView.layer.shadowOpacity = 0.1f;
    cell.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    cell.contentView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,
                                                                                            0,
                                                                                            cell.frame.size.width,
                                                                                            cell.frame.size.height)
                                                                    cornerRadius:7.0f] CGPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 0 ) {
        CGSize titleConstraint = CGSizeMake(CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING - MINGLE_RATING_WIDTH - MINGLE_RATING_PADDING, 400);
        CGSize titleSize = [self.thread.title sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE]
                                         constrainedToSize:titleConstraint
                                             lineBreakMode:UILineBreakModeWordWrap];
        return titleSize.height + 70.0f;
    }
    if ( self.threadPosts.count < 1 ) {
        return 40.0f;
    }
    
    ThreadPost *post = self.threadPosts[indexPath.row];
    CGSize bodyContraint = CGSizeMake(CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING - IMAGE_SIZE - CELL_ELEMENT_PADDING - MINGLE_RATING_PADDING, 400);
    CGSize bodySize = [post.body sizeWithFont:[UIFont systemFontOfSize:BODY_TEXT_SIZE]
                            constrainedToSize:bodyContraint
                                lineBreakMode:UILineBreakModeWordWrap];
    
    return bodySize.height + 70.0f;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self submitPost];
    return YES;
}

#pragma mark - Keyboard Motion

- (void)keyboardWillShow:(NSNotification*)n {
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Move the toolbar
    CGRect viewFrame = self.navigationController.view.frame;
    viewFrame.size.height -= keyboardSize.height - TABBAR_HEIGHT;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [UIView setAnimationDuration:SCROLL_TIME];
    [self.navigationController.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

- (void)keyboardWillDisappear:(NSNotification*)n {
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    // Move the toolbar
    CGRect viewFrame = self.navigationController.view.frame;
    viewFrame.size.height += keyboardSize.height - TABBAR_HEIGHT;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [UIView setAnimationDuration:SCROLL_TIME];
    [self.navigationController.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

#pragma mark - Managing Thread Posts

- (void)submitPost {
    NSString *title = self.textField.text;
    if ( [title length] > 0 ) {
        // Save thread
        NSDictionary *params = @{@"body" : title,
        @"thread_id":@(self.thread.thread_id)};
        [ConnectionManager serverRequest:@"POST"
                              withParams:params
                                     url:THREAD_SUBMIT_POST_URL
                                callback:^(NSHTTPURLResponse *response, NSData *data) {
                                    [self loadThreadFromData:data];
                                }];
    }
    
}

- (void)loadThreadFromData:(NSData*)data {
    // Parse the response into ThreadPosts
    NSError *e = nil;
    NSDictionary *threadData = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&e];
    NSArray *postsData = threadData[@"posts"];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MM/dd/yyyy H:m:s";
    self.threadPosts = [NSMutableArray new];
    for ( NSDictionary *postDict in postsData ) {
        User *user = [[User alloc] initWithName:[NSString stringWithFormat:@"%@ %@",
                                                 postDict[@"user"][@"first_name"],
                                                 postDict[@"user"][@"last_name"]]
                                       username:postDict[@"user"][@"username"]];
        ThreadPost *post = [[ThreadPost alloc] initWithBody:postDict[@"body"]
                                               date_created:[formatter dateFromString:postDict[@"date_created"]]
                                                    upvotes:[postDict[@"upvotes"] intValue]
                                                  downvotes:[postDict[@"downvotes"] intValue]
                                              threadpost_id:[postDict[@"id"] intValue]];
        post.user = user;
        [self.threadPosts addObject:post];
    }
    
    // Parse the rest of the thread
    User *user = [[User alloc] initWithName:[NSString stringWithFormat:@"%@ %@",
                                             threadData[@"user_creator"][@"first_name"],
                                             threadData[@"user_creator"][@"last_name"]]
                                   username:threadData[@"user_creator"][@"username"]];
    
    Thread *thread = [[Thread alloc] initWithTitle:threadData[@"title"]
                                      date_created:[formatter dateFromString:threadData[@"date_created"]]
                                           upvotes:[threadData[@"upvotes"] intValue]
                                         downvotes:[threadData[@"downvotes"] intValue]
                                             posts:self.threadPosts
                                         thread_id:[threadData[@"id"] intValue]];
    thread.user_creator = user;
    self.thread = thread;
    
    [self.textField setText:@""];
    
    [self.tableView reloadData];
}

- (void)giveRating:(int)rating toThreadPostWithId:(int)threadpost_id {
    // rate the thread
    NSDictionary *params = @{ @"user_rating" : @(rating),
    @"id" : @(threadpost_id) };
    
    [ConnectionManager serverRequest:@"POST"
                          withParams:params
                                 url:THREAD_RATE_POST_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                
                                [self loadThreadFromData:d];
     }];
}

@end
