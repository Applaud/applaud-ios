//
//  PhotoCommentViewController.m
//  ApplaudIOS
//
//  Created by Peter Fogg on 8/7/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "PhotoCommentViewController.h"

@interface PhotoCommentViewController ()

@end

@implementation PhotoCommentViewController

- (id)initWithPhoto:(BusinessPhoto *)businessPhoto
{
    self = [super init];
    if (self) {
        self.scrollView = [[UIScrollView alloc]
                           initWithFrame:CGRectMake(0,
                                                    0,
                                                    self.view.frame.size.width,
                                                    self.view.frame.size.height)];
        self.scrollView.contentSize = self.scrollView.frame.size;
        self.view = self.scrollView;
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5,
                                                                          50,
                                                                          20)];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view addSubview:backButton];
        _businessPhoto = businessPhoto;
        self.comments = [[NSMutableArray alloc] init];
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.tableView = [[UITableView alloc]
                          initWithFrame:CGRectMake(0,
                                                   30,
                                                   self.view.frame.size.width,
                                                   350)
                          style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.allowsSelection = NO;
        self.tableView.sectionHeaderHeight = 5;
        self.tableView.sectionFooterHeight = 0;
        self.commentField = [[UITextField alloc] initWithFrame:CGRectMake(10,
                                                                          400,
                                                                          self.view.frame.size.width - 60,
                                                                          30)];
        self.commentField.layer.cornerRadius = 3.0f;
        self.commentField.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.commentField.layer.borderWidth = 2.0;
        self.commentField.delegate = self;
        self.numChars = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 45,
                                                                  self.commentField.frame.origin.y,
                                                                  40,
                                                                  self.commentField.frame.size.height)];
        self.numChars.text = @"1000";
        [self.view addSubview:self.tableView];
        [self.view addSubview:self.commentField];
        [self.view addSubview:self.numChars];
        [self getComments];
    }
    return self;
}

-(void)setAppDelegate:(AppDelegate *)appDelegate {
    _appDelegate = appDelegate;
    UIColor *color = _appDelegate.currentBusiness.secondaryColor;
    self.view.backgroundColor = color;
    self.tableView.backgroundColor = color;
    self.numChars.backgroundColor = color;
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

-(void)getComments {
    NSDictionary *params = @{@"photo": @(self.businessPhoto.photo_id)};
    [ConnectionManager serverRequest:@"GET" withParams:params
                                 url:GET_PHOTO_COMMENTS_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                [self handleComments:d];
                            }];
}

-(void)handleComments:(NSData *)data {
    NSArray *comments = [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:nil];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM/dd/yyyy";
    for(NSDictionary *dict in comments) {
        NSDictionary *user = dict[@"user"];
        Comment *c = [[Comment alloc] initWithText:dict[@"text"]
                                          photo_id:[dict[@"businessphoto"] intValue]
                                           user_id:[user[@"id"] intValue]
                                              date:[format dateFromString:dict[@"date_created"]]
                                        comment_id:[dict[@"id"] intValue]
                                         firstName:user[@"first_name"]
                                          lastName:user[@"last_name"]];
        [self.comments addObject:c];
    }
    [self.tableView reloadData];
}

-(void)postComment:(NSString *)comment {
    NSDictionary *params = @{@"photo_id": @(self.businessPhoto.photo_id),
                             @"text": comment};
    [ConnectionManager serverRequest:@"POST" withParams:params
                                 url:PHOTO_COMMENT_URL
                            callback:^(NSHTTPURLResponse *r, NSData *d) {
                                NSDictionary *dict = [NSJSONSerialization
                                                      JSONObjectWithData:d
                                                      options:0
                                                      error:nil];
                                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                                format.dateFormat = @"MM/dd/yyyy";
                                Comment *c = [[Comment alloc]
                                              initWithText:dict[@"text"]
                                              photo_id:[dict[@"businessphoto"] intValue]
                                              user_id:[dict[@"user"][@"id"] intValue]
                                              date:[format dateFromString:dict[@"date_created"]]
                                              comment_id:[dict[@"id"] intValue]
                                              firstName:dict[@"user"][@"first_name"]
                                              lastName:dict[@"user"][@"last_name"]];
                                [self.comments addObject:c];
                                NSLog(@"%@", self.comments);
                                [self.tableView reloadData];
                            }];
}

#pragma mark -
#pragma Keyboard methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,
                                             self.scrollView.contentSize.height + 210);
    [self.scrollView setContentOffset:CGPointMake(0, 210) animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,
                                             self.scrollView.contentSize.height - 210);
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(textField.text.length) {
        [self postComment:textField.text];
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
        self.numChars.text = [NSString stringWithFormat:@"%d",
                              1000 - textField.text.length -
                              (range.length == 0 ? 1 : -1)];
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma Table view delegate and data source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.comments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    PhotoCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[PhotoCommentCell alloc] initWithComment:self.comments[indexPath.section]
                                                   style:UITableViewCellStyleDefault
                                         reuseIdentifier:cellIdentifier];
    }
    cell.comment = self.comments[indexPath.section];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize textSize = [[self.comments[indexPath.section] text] sizeWithFont:[UIFont systemFontOfSize:COMMENT_SIZE]
                                                           constrainedToSize:CGSizeMake(280 - 2*CELL_PADDING,
                                                                                        1000)
                                                               lineBreakMode:UILineBreakModeWordWrap];
    return textSize.height + 2*CELL_PADDING + ELEMENT_MARGIN + NAME_HEIGHT;

}

#pragma mark -
#pragma Other methods

-(void)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
