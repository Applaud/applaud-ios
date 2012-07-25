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
@synthesize image, nameLabel;
@synthesize tableView = _tableView;
@synthesize ratingDimensions = _ratingDimensions;


- (id)initWithEmployee:(Employee *)e {
    if ( self = [super init] ) {
        _employee = e;
        _ratingDimensions = [[NSMutableDictionary alloc] init];
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
    
    // Set up the table
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 
                                        self.tableView.frame.origin.y, 
                                        self.tableView.frame.size.width,
                                        1000)];
    
//    // The y-coordinate of the first rating field
//    int dimensionStart = RATING_FIELDS_BEGIN;
//    if ( self.employee.bio != (id)[NSNull null] && self.employee.bio.length > 0 ) {
//        [self.bioField setText:self.employee.bio];
//    }
//    else {
//        int spaceGained = bioField.bounds.size.height + bioLabel.bounds.size.height;
//        [self.bioField removeFromSuperview];
//        [self.bioLabel removeFromSuperview];
//        dimensionStart -= spaceGained;
//    }
//    
//    // Keeps track of where we're putting labels/sliders
//    int curr_y = dimensionStart;
//    // i will be used as a tag for UISliders, so we can identify which one is which later.
//    int i = 0;
//    // Parse all of the rating dimensions
//    for ( NSDictionary *dimension_dict in self.employee.ratingDimensions ) {
//        NSString *dimension = [dimension_dict objectForKey:@"title"];
//        // Create a label
//        UILabel *dimensionLabel = [[UILabel alloc] 
//                                   initWithFrame:CGRectMake(RATING_FIELD_SPACING,
//                                                            curr_y,
//                                                            self.view.frame.size.width-(2*RATING_FIELD_SPACING),
//                                                            RATING_FIELD_HEIGHT/2)];
//        [dimensionLabel setText:dimension];
//        dimensionLabel.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
//        [self.view addSubview:dimensionLabel];
//        if([[dimension_dict objectForKey:@"is_text"] boolValue]) {
//            UITextField *dimensionText = [[UITextField alloc]
//                                          initWithFrame:CGRectMake(RATING_FIELD_SPACING,
//                                                                   curr_y + 30,
//                                                                   self.view.frame.size.width-(2*RATING_FIELD_SPACING),
//                                                                   RATING_FIELD_HEIGHT/2)];
//            dimensionText.returnKeyType = UIReturnKeyDone;
//            dimensionText.delegate = self;
//            dimensionText.borderStyle = UITextBorderStyleRoundedRect;
//            dimensionText.tag = i++;
//            [self.ratingDimensions setObject:dimension forKey:[NSNumber numberWithInt:dimensionText.tag]];
//            [self.view addSubview:dimensionText];
//        }
//        else {
//            UISlider *dimensionSlider = [[UISlider alloc] 
//                                         initWithFrame:CGRectMake(RATING_FIELD_SPACING, 
//                                                                  curr_y + 30,
//                                                                  self.view.frame.size.width-(2*RATING_FIELD_SPACING),
//                                                                  RATING_FIELD_HEIGHT)];
//            curr_y += 20;
//            [dimensionSlider setMinimumValue:0.0f];
//            [dimensionSlider setMaximumValue:1.0f];
//            dimensionSlider.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
//            dimensionSlider.tag = i++;
//            [self.ratingDimensions setObject:dimension forKey:[NSNumber numberWithInt:dimensionSlider.tag]]; // NSNumbers let us put an int into the dictionary
//            [self.view addSubview:dimensionSlider];
//        }
//        curr_y += RATING_FIELD_HEIGHT;
//    }
    
    // Set up the 'submit' button
    self.submitButton.frame = CGRectMake(self.view.frame.size.width - 100,
                                         VIEW_PADDING 
                                         + self.nameLabel.frame.size.height 
                                         + VIEW_ELEMENT_PADDING 
                                         + self.tableView.frame.size.height
                                         + VIEW_ELEMENT_PADDING,
                                         75,
                                         50);
    
    // Tell our scroll view how big its contents are, so we can scroll in it.
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             1000.0f);
//                                             curr_y+(2*RATING_FIELD_HEIGHT));
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
    switch ( indexPath.section ) {
        case 0:
            if ( bioCellExpanded ) {
                CGSize bioLabelSize = [self.employee.bio sizeWithFont:[UIFont systemFontOfSize:CONTENT_SIZE]
                                                    constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 2*CELL_PADDING, 200)
                                                        lineBreakMode:UILineBreakModeWordWrap];
                return 2*CELL_PADDING + CELL_ELEMENT_PADDING + bioLabelSize.height + TITLE_LABEL_HEIGHT;
            }
            return 2*CELL_PADDING + TITLE_LABEL_HEIGHT;
            break;
        case 1:
            return 2*CELL_PADDING + TITLE_LABEL_HEIGHT + RATING_FIELD_HEIGHT + CELL_ELEMENT_PADDING;
            break;
    }
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    switch ( indexPath.section ) {
        case 0:
        {
            EmployeeBioCell *bioCell = (EmployeeBioCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            bioCellExpanded = !bioCellExpanded;
            
            // Perform animations if necessary
            [self.tableView beginUpdates];    
            [self.tableView endUpdates];
            
            [bioCell toggleBio];
        }
            break;
        case 1:
            break;
    }

}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch ( section ) {
        case 0:
            return @"Profile";
            break;
        case 1:
            return @"Rate me";
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ( section ) {
        case 0:
            // Just the bio
            return 1;
            break;
        case 1:
            // The number of ratings
            return self.employee.ratingDimensions.count;
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // One for the bio, another for the ratings
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EmployeeViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    static int ratingCount = 0;
    
    if ( nil == cell ) {        
        switch ( indexPath.section ) {
            case 0:
                cell = [[EmployeeBioCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cellIdentifier
                                                     employee:self.employee];
                // Initialize with "Bio" title
                cell.textLabel.text = @"Bio";
                cell.textLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
                break;
            case 1:
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
                responseWidget.tag = ratingCount++;
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
                    [cell.contentView addSubview:slider];
                }
                [cell.contentView addSubview:responseWidget];
                break;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)submitButtonPressed:(UIButton *)sender {
    NSMutableDictionary *em = [[NSMutableDictionary alloc] init];
    [em setObject:self.employee.firstName forKey:@"first_name"];
    [em setObject:self.employee.lastName forKey:@"last_name"];
    [em setObject:[NSNumber numberWithInt: self.employee.employee_id] forKey:@"id"];
    NSMutableDictionary *ratings = [[NSMutableDictionary alloc] init];
    for( UIView *view in self.view.subviews){
        if([view isKindOfClass:[UISlider class]]){
            UISlider *slider = (UISlider *)view;
            [ratings setObject:[NSNumber numberWithFloat:slider.value]
                        forKey:[[[self.employee.ratingDimensions objectAtIndex:slider.tag] objectForKey:@"id"] description]];
        }
        else if([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            [ratings setObject:field.text
                        forKey:[[[self.employee.ratingDimensions objectAtIndex:field.tag] objectForKey:@"id"] description]];
        }
    }
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret setObject:em forKey:@"employee"];
    [ret setObject:ratings forKey:@"ratings"];
    [ConnectionManager serverRequest:@"POST" withParams:ret url:EVALUATE_URL callback:nil];
    [[[UIAlertView alloc] initWithTitle:@"Thanks!"
                                message:@"We appreciate your feedback."
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
    NSLog(@"%@", self.parentViewController);
    [(UITabBarController *)self.appDelegate.window.rootViewController setSelectedIndex:4];
    UINavigationController *parent = (UINavigationController *)self.parentViewController;
    [parent popViewControllerAnimated:NO];
    EmployeeListViewController *elvc = [parent.viewControllers objectAtIndex:0];
    //    [elvc.employeeControllers replaceObjectAtIndex:[[elvc.tableView indexPathForSelectedRow] row]
    [elvc.employeeControllers replaceObjectAtIndex:[[elvc.tableView indexPathForSelectedRow] row] withObject:[[NSNull alloc] init]];
}

@end
