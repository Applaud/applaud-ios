//
//  EmployeeViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "EmployeeViewController.h"
#import "EmployeeListViewController.h"
#import "Employee.h"
#import "ConnectionManager.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "EmployeeBioCell.h"
#import "EmployeeDisplayConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation EmployeeViewController
@synthesize appDelegate = _appDelegate;
@synthesize submitButton;
@synthesize employee = _employee;
@synthesize scrollView = _scrollView;
@synthesize image, nameLabel, titleLabel, bioContentLabel, bioLabel;
@synthesize tableView = _tableView;
@synthesize ratingDimensions = _ratingDimensions;


- (id)initWithEmployee:(Employee *)e {
    if ( self = [super init] ) {
        _employee = e;
        _ratingDimensions = [[NSMutableDictionary alloc] init];
        widgetList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.image setImageWithURL:self.employee.imageURL
                        success:^(UIImage *img) {
                            [self loadViewWithImage:img];
                        } failure:^(NSError *error) {
                            [self loadViewWithImage:[UIImage imageNamed:@"blankPerson.jpg"]];
                        }];
    
    // Bio cell is collapsed at init
    bioCellExpanded = NO;
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:self.view.window];
}

- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setScrollView:nil];
    [self setSubmitButton:nil];
    [self setImage:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
 * called by viewDidLoad. This does the view layout. We need
 * to break up layout into two pieces, since image download happens asynchronously.
 */
- (void)loadViewWithImage:(UIImage *)img {
    // Resize and position the image
    float scaleFactor = img.size.width * img.scale / IMAGE_SIZE;
    self.image.image = [UIImage imageWithCGImage:img.CGImage
                                           scale:scaleFactor
                                     orientation:UIImageOrientationUp];
    [self.image sizeToFit];
    CGRect imageRect = self.image.frame;
    imageRect.origin.x = VIEW_PADDING;
    imageRect.origin.y = VIEW_PADDING;
    self.image.frame = imageRect;
    
    // Add a border around the image
    CALayer *imageLayer = self.image.layer;
    imageLayer.borderWidth = 3.0f;
    imageLayer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    // Set up the name label
    [self.nameLabel setText:[NSString stringWithFormat:@"%@ %@",
                             self.employee.firstName, self.employee.lastName]];
    CGRect nameTextRect = self.nameLabel.frame;
    nameTextRect.origin.x = VIEW_PADDING + self.image.frame.size.width + VIEW_ELEMENT_PADDING;
    nameTextRect.origin.y = VIEW_PADDING;
    self.nameLabel.frame = nameTextRect;
    
    // Set up the employee's title label
    [self.titleLabel setText:self.employee.ratingProfileTitle];
    CGRect titleTextRect = self.titleLabel.frame;
    titleTextRect.origin.x = VIEW_PADDING + self.image.frame.size.width + VIEW_ELEMENT_PADDING;
    titleTextRect.origin.y = nameTextRect.origin.y + nameTextRect.size.height + VIEW_ELEMENT_PADDING;
    self.titleLabel.frame = titleTextRect;
    
    // Set up bio labels
    CGRect bioTextRect;
    if ( self.employee.bio.length == 0 ) {
        [self.bioLabel setHidden:YES];
        bioTextRect = titleTextRect;
    } else {
        // Label "Bio:"
        CGRect bioLabelRect = self.bioLabel.frame;
        bioLabelRect.origin.x = VIEW_PADDING + self.image.frame.size.width + VIEW_ELEMENT_PADDING;
        bioLabelRect.origin.y = imageRect.origin.y + imageRect.size.height - BIO_LABEL_HEIGHT;
        self.bioLabel.frame = bioLabelRect;
        
        // Bio content label
        [self.bioContentLabel setText:self.employee.bio];
        self.bioContentLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.bioContentLabel.numberOfLines = 0;
        [self.bioContentLabel setFont:[UIFont systemFontOfSize:BIO_SIZE]];
        [self.bioContentLabel sizeToFit];
        bioTextRect = self.bioContentLabel.frame;
        bioTextRect.origin.x = VIEW_PADDING;
        bioTextRect.origin.y = imageRect.origin.y + imageRect.size.height + VIEW_ELEMENT_PADDING;
        self.bioContentLabel.frame = bioTextRect;
    }

    // Set up the table -- the '110' on the end accounts for section headings space + other padding on the table view.
    // By customizing headers, etc., we could get a more exact figure.
    CGFloat tableHeight = self.employee.ratingDimensions.count * (RATING_FIELD_HEIGHT 
                                                                  + TITLE_LABEL_HEIGHT 
                                                                  + CELL_ELEMENT_PADDING
                                                                  + 2*CELL_PADDING) + TITLE_LABEL_HEIGHT + 2*CELL_PADDING + 110;
    [self.tableView setFrame:CGRectMake(0, 
                                        bioTextRect.origin.y + bioTextRect.size.height + VIEW_ELEMENT_PADDING,
                                        self.view.frame.size.width, 
                                        tableHeight)];
    self.tableView.scrollEnabled = NO;
    
    // Set up the 'submit' button
    self.submitButton.frame = CGRectMake(VIEW_PADDING,
                                         VIEW_PADDING 
                                         + self.nameLabel.frame.size.height 
                                         + VIEW_ELEMENT_PADDING 
                                         + self.tableView.frame.size.height
                                         + VIEW_ELEMENT_PADDING,
                                         self.view.frame.size.width - 2*VIEW_PADDING,
                                         50);
    // Make a submit button on the navigation bar as well
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(submit)];
    [[self navigationItem] setRightBarButtonItem:submitItem];
    
    // Set up the scrollable area for the scrollview
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             2*VIEW_PADDING
                                             + IMAGE_SIZE
                                             + VIEW_ELEMENT_PADDING
                                             + self.tableView.frame.size.height);
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITextFieldDelegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    selectedTextRect = textField.bounds;
    selectedTextRect = [textField convertRect:selectedTextRect toView:self.view];
    previousOffset = [(UIScrollView*)self.view contentOffset];
}

#pragma mark -
#pragma mark Keyboard Handling

- (void)keyboardWillHide:(NSNotification *)n
{
    [(UIScrollView*)self.view setContentOffset:previousOffset animated:YES];

    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint offsetPoint = selectedTextRect.origin;
    offsetPoint.x = 0;
    offsetPoint.y -= keyboardSize.height - selectedTextRect.size.height - NAVBAR_SIZE;
    [(UIScrollView*)self.view setContentOffset:offsetPoint animated:YES];
  
    keyboardIsShown = YES;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.contentView.layer setMasksToBounds:YES];
    
    // Set shape and color
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 7.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 2*CELL_PADDING + TITLE_LABEL_HEIGHT + RATING_FIELD_HEIGHT + CELL_ELEMENT_PADDING;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    // nothing yet
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Rate me";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.employee.ratingDimensions.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Ratings section
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EmployeeViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( nil == cell ) {        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        
        // Label for the respective rated dimension title
        UILabel *ratedDimensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING,
                                                                                 CELL_PADDING,
                                                                                 self.tableView.frame.size.width
                                                                                 - 2*CELL_PADDING - 2*VIEW_PADDING,
                                                                                 TITLE_LABEL_HEIGHT)];
        ratedDimensionLabel.text = [[self.employee.ratingDimensions objectAtIndex:indexPath.row] objectForKey:@"title"];
        [cell.contentView addSubview:ratedDimensionLabel];
        
        // Add correct widget for this rateddimension
        UIView *responseWidget = nil;
        CGRect responseFrame = CGRectMake(CELL_PADDING,
                                          CELL_PADDING + TITLE_LABEL_HEIGHT + CELL_ELEMENT_PADDING,
                                          self.tableView.frame.size.width
                                          - 2*CELL_PADDING - 2*VIEW_PADDING,
                                          RATING_FIELD_HEIGHT);
        
        if ( [[[self.employee.ratingDimensions objectAtIndex:indexPath.row] objectForKey:@"is_text"] boolValue] ) {
            UITextField *textField = [[UITextField alloc] initWithFrame:responseFrame];
            [textField setReturnKeyType:UIReturnKeyDone];
            [textField setDelegate:self];
            textField.layer.cornerRadius = 5;
            textField.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
            textField.layer.borderWidth = 2.0;
            
            responseWidget = textField;
        } else {
            // Add the slider
            UISlider *slider = [[UISlider alloc] initWithFrame:responseFrame];
            responseWidget = slider;
            [cell.contentView addSubview:slider];
        }
        // Set the tag of the widget based on the ID of the RatedDimension
        responseWidget.tag = [[[self.employee.ratingDimensions objectAtIndex:indexPath.row] objectForKey:@"id"] intValue];
        [widgetList addObject:responseWidget];
        
        [cell.contentView addSubview:responseWidget];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)submitButtonPressed:(UIButton *)sender {
    [self submit];
}

- (void)submit {
    // Basic employee information: first name, last name, id
    NSMutableDictionary *em = [[NSMutableDictionary alloc] init];
    [em setObject:self.employee.firstName forKey:@"first_name"];
    [em setObject:self.employee.lastName forKey:@"last_name"];
    [em setObject:[NSNumber numberWithInt: self.employee.employee_id] forKey:@"id"];
    
    // Build dictionary for ratings
    NSMutableDictionary *ratings = [[NSMutableDictionary alloc] init];
    for ( UIView *view in widgetList ) {
        if([view isKindOfClass:[UISlider class]]){
            UISlider *slider = (UISlider *)view;
            [ratings setObject:[NSNumber numberWithFloat:slider.value]
                        forKey:[[NSNumber numberWithInt:slider.tag] description]];
        }
        else if([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            [ratings setObject:field.text
                        forKey:[[NSNumber numberWithInt:field.tag] description]];
        }
    }
    
    // Build the final dictionary to send to the server in JSON
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret setObject:em forKey:@"employee"];
    [ret setObject:ratings forKey:@"ratings"];
    
    // Send request to the server
    [ConnectionManager serverRequest:@"POST" withParams:ret url:EVALUATE_URL callback:nil];
    
    // Thank the user
    [[[UIAlertView alloc] initWithTitle:@"Thanks!"
                                message:@"We appreciate your feedback."
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
    
    // Switch to another part of the app
    [(UITabBarController *)self.appDelegate.window.rootViewController setSelectedIndex:4];
    UINavigationController *parent = (UINavigationController *)self.parentViewController;
    [parent popViewControllerAnimated:NO];
    EmployeeListViewController *elvc = [parent.viewControllers objectAtIndex:0];
    // Are we nulling out the employee view here???
    [elvc.employeeControllers replaceObjectAtIndex:[[elvc.tableView indexPathForSelectedRow] row] withObject:[[NSNull alloc] init]];
}

@end
