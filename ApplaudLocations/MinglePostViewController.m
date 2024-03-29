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
#import "UIViewController+KeyboardDismiss.h"

@interface MinglePostViewController ()

@end

@implementation MinglePostViewController

- (id)initWithStyle:(UITableViewStyle)style thread:(Thread *)thread
{
    self = [super initWithStyle:style];
    if (self) {
        _thread = thread;
        self.threadPosts = self.thread.threadPosts;
        cellMap = [NSMutableDictionary new];
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self initForKeyboardDismissal];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.thread.title;
    
    [self setHidesBottomBarWhenPushed:YES];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 80, 20.0f)];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    self.textField.placeholder = @"New post...";
    self.textField.layer.cornerRadius = 3.0f;
    self.textField.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    self.textField.layer.borderWidth = 2.0;
    self.textField.backgroundColor = [UIColor whiteColor];
    UIView *paddingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, self.textField.frame.size.height)];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.rightView = paddingView;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    
    
    CGRect tff = self.textField.frame;
    tff.size.height = 30;
    self.textField.frame = tff;
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(submitPost)];
    submitButton.tintColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
    submitButton.title = @"Post";
    UIBarButtonItem *textItem = [[UIBarButtonItem alloc] initWithCustomView:self.textField];
    
    // Back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.toolbarWidgets = [[NSMutableArray alloc] initWithObjects:textItem, submitButton, nil];
    
    // Can scroll to top of posts easily
    self.tableView.scrollsToTop = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set our toolbar items
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self setToolbarItems:self.toolbarWidgets animated:YES];
    self.navigationController.toolbar.tintColor = [UIColor grayColor];
    
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
            cell.mlvc = self.parent;
        } else {
            [cell setThread:self.thread];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    // No posts in this thread yet
    if ( self.threadPosts.count < 1 ) {
        static NSString *CellIdentifier = @"MinglePostCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if ( nil == cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Be the first to post on this thread!";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
    } else {
        [cell setPost:self.threadPosts[indexPath.row]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
    viewFrame.size.height -= keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:SCROLL_TIME];
    [self.navigationController.view setFrame:viewFrame];

    NSLog(@"Content offset of tableview: %f", self.tableView.contentOffset.y);
   
    // Either scroll to the last cell of the tableview, or move the contentOffset of
    // the tableview according to keyboard size. Whichever is more convenient
    NSIndexPath *lastCellIndex = [NSIndexPath indexPathForRow:self.threadPosts.count-1 inSection:1];
    CGRect lastCellRect = [self.tableView rectForRowAtIndexPath:lastCellIndex];
    if ( lastCellRect.origin.y + lastCellRect.size.height - self.tableView.contentOffset.y - keyboardSize.height + 22 < NAVBAR_SIZE )
        [self.tableView scrollToRowAtIndexPath:lastCellIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
    else
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + keyboardSize.height - 22)
                                animated:YES];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

- (void)keyboardWillDisappear:(NSNotification*)n {
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    // Move the toolbar
    CGRect viewFrame = self.navigationController.view.frame;
    viewFrame.size.height += keyboardSize.height;
    
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
                                    
                                    // Jump to the new post
                                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.threadPosts.count-1
                                                                                              inSection:1]
                                                          atScrollPosition:UITableViewScrollPositionBottom
                                                                  animated:YES];
                                }];
    }
    
    [self.textField resignFirstResponder];
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
        NSLog(@"Received prof pic: %@",postDict[@"user"][@"profile_picture"]);
        user.profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,postDict[@"user"][@"profile_picture"]]];
        
        ThreadPost *post = [[ThreadPost alloc] initWithBody:postDict[@"body"]
                                               date_created:[formatter dateFromString:postDict[@"date_created"]]
                                                    upvotes:[postDict[@"upvotes"] intValue]
                                                  downvotes:[postDict[@"downvotes"] intValue]
                                              threadpost_id:[postDict[@"id"] intValue]];
        post.user = user;
        post.my_rating = [postDict[@"my_vote"] intValue];
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
    thread.my_rating = [threadData[@"my_vote"] intValue];
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

#pragma mark - Go Back

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
