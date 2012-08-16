//
//  PhotoCommentViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PhotoCommentViewController.h"
#import "UIViewController+KeyboardDismiss.h"

@interface PhotoCommentViewController ()

@end

@implementation PhotoCommentViewController

- (id)initWithPhoto:(BusinessPhoto *)businessPhoto
{
    self = [super init];
    [self initForKeyboardDismissal];
    if (self) {
        self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.navigationItem.title = @"Comments";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(backButtonPressed)];
        [self.navBar pushNavigationItem:self.navigationItem animated:NO];
        self.scrollView = [[UIScrollView alloc]
                           initWithFrame:CGRectMake(0,
                                                    -44,
                                                    self.view.frame.size.width,
                                                    self.view.frame.size.height-20)];
        NSLog(@"The height is... %f", self.view.frame.size.height);
        self.scrollView.contentSize = self.scrollView.frame.size;
        //self.scrollView.bounds = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
        
        // self.view = self.scrollView;
        _businessPhoto = businessPhoto;
        self.comments = [[NSMutableArray alloc] init];
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.tableView = [[UITableView alloc]
                          initWithFrame:CGRectMake(0,
                                                   84,
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.height-106)
                          style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.allowsSelection = NO;
        self.tableView.sectionHeaderHeight = 5;
        self.tableView.sectionFooterHeight = 0;
        
        self.commentField = [[UITextField alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          self.view.frame.size.width - 80,
                                                                          30.0f)];
        self.commentField.returnKeyType = UIReturnKeyGo;
        self.commentField.layer.cornerRadius = 3.0f;
        self.commentField.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.commentField.layer.borderWidth = 2.0;
        self.commentField.backgroundColor = [UIColor whiteColor];
        self.commentField.delegate = self;
        UIView *paddingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, self.commentField.frame.size.height)];
        self.commentField.leftView = paddingView;
        self.commentField.leftViewMode = UITextFieldViewModeAlways;
        self.commentField.rightView = paddingView;
        self.commentField.rightViewMode = UITextFieldViewModeAlways;        
        
        UIBarButtonItem *textField = [[UIBarButtonItem alloc] initWithCustomView:self.commentField];
        
        UIBarButtonItem *commentButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                          style:UIBarButtonItemStyleDone
                                                                         target:self
                                                                         action:@selector(postComment)];
        commentButton.tintColor = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0];
        
        // Make the 'Comment' toolbar at the very bottom of the screen
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 416, 320, 44)];
        self.toolbar.tintColor = [UIColor grayColor];
        [self.toolbar setItems:@[textField, commentButton]];
        
        [self.scrollView addSubview:self.tableView];
        [self.view addSubview:self.scrollView];
        [self.view addSubview:self.navBar];
        [self.view addSubview:self.toolbar];
        [self getComments:YES];
    }
    return self;
}

-(void)setAppDelegate:(AppDelegate *)appDelegate {
    _appDelegate = appDelegate;
    UIColor *color = _appDelegate.currentBusiness.secondaryColor;
    self.view.backgroundColor = color;
    self.tableView.backgroundColor = color;
    self.navBar.tintColor =_appDelegate.currentBusiness.primaryColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)getComments:(BOOL)isFirst {
    NSDictionary *params = @{@"photo": @(self.businessPhoto.photo_id)};
    [ConnectionManager serverRequest:@"GET" withParams:params
                                 url:GET_PHOTO_COMMENTS_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                self.comments = [[NSMutableArray alloc] init];
                                [self handleComments:d isFirst:isFirst];
                            }];
}

-(void)handleComments:(NSData *)data isFirst:(BOOL)isFirst {
    NSArray *comments = [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:nil];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM/dd/yyyy H:m:s";
    for(NSDictionary *dict in comments) {
        NSDictionary *user = dict[@"user"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,user[@"profile_picture"]]];
        Comment *c = [[Comment alloc] initWithText:dict[@"text"]
                                          photo_id:[dict[@"businessphoto"] intValue]
                                           user_id:[user[@"id"] intValue]
                                 profilePictureURL:url
                                              date:[format dateFromString:dict[@"date_created"]]
                                        comment_id:[dict[@"id"] intValue]
                                         firstName:user[@"first_name"]
                                          lastName:user[@"last_name"]
                                             votes:[dict[@"votes"] intValue]];
        [self.comments addObject:c];
    }
    [self.tableView reloadData];

    
    if(! isFirst){
        int offset = self.tableView.contentSize.height - 370;//self.tableView.frame.size.height;
        NSLog(@"The scroll view height is...%f", self.scrollView.frame.size.height);
        CGPoint bottomOffset = CGPointMake(0, offset);
        
        [UIView animateWithDuration:.25 animations:^(void){
            
            self.tableView.contentOffset = bottomOffset;
            
        }];
    }

}

-(void)postComment {
    NSString *comment = self.commentField.text;
    [self.commentField resignFirstResponder];
    if([comment isEqualToString:@""]) {
        return;
    }
    NSDictionary *params = @{@"photo_id": @(self.businessPhoto.photo_id),
                             @"text": comment};
    [ConnectionManager serverRequest:@"POST" withParams:params
                                 url:PHOTO_COMMENT_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
//                                NSDictionary *dict = [NSJSONSerialization
//                                                      JSONObjectWithData:d
//                                                      options:0
//                                                      error:nil];
//                                NSDateFormatter *format = [[NSDateFormatter alloc] init];
//                                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,dict[@"profile_picture"]]];
//                                format.dateFormat = @"MM/dd/yyyy H:m:s";
//                                Comment *c = [[Comment alloc]
//                                              initWithText:dict[@"text"]
//                                              photo_id:[dict[@"businessphoto"] intValue]
//                                              user_id:[dict[@"user"][@"id"] intValue]
//                                              profilePictureURL:url
//                                              date:[format dateFromString:dict[@"date_created"]]
//                                              comment_id:[dict[@"id"] intValue]
//                                              firstName:dict[@"user"][@"first_name"]
//                                              lastName:dict[@"user"][@"last_name"]
//                                              votes:[dict[@"votes"] intValue]];
//                                
//                                [self.comments addObject:c];
//                                [self.tableView reloadData];
                                [self getComments:NO];
                                

                            }];
    self.commentField.text = @"";
}

#pragma mark -
#pragma Keyboard methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    // Set the content offset so that the last comment is right above the keyboard
    [self.tableView layoutIfNeeded];
    //float scrollViewOffset =  self.tableView.contentSize.height > self.tableView.frame.size.height ? 214: 214- self.tableView.contentSize.height;
    float tableViewOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
        
    [UIView animateWithDuration:0.25f animations:^(void){
        self.toolbar.frame = CGRectMake(0, 200, self.toolbar.frame.size.width, self.toolbar.frame.size.height);
        if( self.tableView.contentSize.height > self.tableView.frame.size.height){
            self.scrollView.bounds = CGRectMake(0,
                                                214,
                                                self.scrollView.frame.size.width,
                                                self.scrollView.frame.size.height);
        }
        self.tableView.bounds = CGRectMake(0,
                                           tableViewOffset < 0 ? 0 : tableViewOffset,
                                           self.tableView.frame.size.width,
                                           self.tableView.frame.size.height);
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {

    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
    [UIView animateWithDuration:0.25f animations:^(void){
        self.toolbar.frame = CGRectMake(0, 416, self.toolbar.frame.size.width, self.toolbar.frame.size.height);
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(textField.text.length) {
        [self postComment];
    }
    textField.text = @"";
    return NO;
}

/*
 * Enforces the 1000-character limit on comments. range.length is 1 if we're
 * deleting a character, and 0 otherwise.
 */
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField.text.length < 1000 || range.length == 1) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma Table view delegate and data source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    PhotoCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[PhotoCommentCell alloc] initWithComment:self.comments[indexPath.row]
                                                   style:UITableViewCellStyleDefault
                                         reuseIdentifier:cellIdentifier];
    }
    cell.comment = self.comments[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize bodyContraint = CGSizeMake(CELL_WIDTH - 2*CELL_MARGIN - 2*CELL_PADDING - 110, 400);
    CGSize bodySize = [[self.comments[indexPath.row] text] sizeWithFont:[UIFont systemFontOfSize:BODY_TEXT_SIZE]
                            constrainedToSize:bodyContraint
                                lineBreakMode:UILineBreakModeWordWrap];
    
    return bodySize.height + 70.0f;
}

#pragma mark -
#pragma Other methods

-(void)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
