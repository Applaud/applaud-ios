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

- (id)initWithEmployee:(Employee *)e {
    if ( self = [super init] ) {
        _employee = e;
        _ratingDimensions = [[NSMutableDictionary alloc] init];
        widgetList = [[NSMutableArray alloc] init];
        
        clearButtonTable = [[NSMutableDictionary alloc] init];
        sliderLabelTable = [[NSMutableDictionary alloc] init];
        sliderTable = [[NSMutableDictionary alloc] init];
        activityTable = [[NSMutableDictionary alloc] init];
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
    
    // Set up the profile view. This contains the name, title, bio, biolabel as subviews
    self.profileView.frame = CGRectMake(0, 0,
                                        self.view.frame.size.width,
                                        bioTextRect.origin.y + bioTextRect.size.height+VIEW_ELEMENT_PADDING);
    // Some nice visual FX for the profile view
    self.profileView.layer.shadowRadius = 5.0f;
    self.profileView.layer.shadowOpacity = 0.2f;
    self.profileView.layer.shadowOffset = CGSizeMake(1, 0);

    // Set up the table -- the '230' on the end accounts for section headings space + other padding on the table view.
    // By customizing headers, etc., we could get a more exact figure.
    CGFloat tableHeight = self.employee.ratingDimensions.count * (RATING_FIELD_HEIGHT 
                                                                  + TITLE_LABEL_HEIGHT 
                                                                  + CELL_ELEMENT_PADDING
                                                                  + 2*CELL_PADDING) + 2 * CELL_PADDING + TITLE_LABEL_HEIGHT + CELL_GAP + 20;

    [self.tableView setFrame:CGRectMake(0, 
                                        self.profileView.frame.origin.y + self.profileView.frame.size.height - CELL_GAP - 15,
                                        self.view.frame.size.width, 
                                        tableHeight)];
    self.tableView.scrollEnabled = NO;
  
    // Make a submit button on the navigation bar
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(submit)];
    [[self navigationItem] setRightBarButtonItem:submitItem];
    
    // Set up the scrollable area for the scrollview
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             self.tableView.frame.origin.y
                                             + tableHeight
                                             + VIEW_ELEMENT_PADDING
                                             + VIEW_PADDING);
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
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
    CGSize keyboardSize = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
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
    if ( indexPath.row == 0 )
        return TITLE_LABEL_HEIGHT + 2*CELL_PADDING + CELL_GAP;
    // Calculate other heights
    return 2*CELL_PADDING + TITLE_LABEL_HEIGHT + RATING_FIELD_HEIGHT + CELL_ELEMENT_PADDING;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    // nothing yet
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Include an empty cell at the top for looks (hide under name tag)
    return self.employee.ratingDimensions.count + 1;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Blank cell at the top of the page
        if ( indexPath.row == 0 ) {
            UILabel *applaudLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, CELL_PADDING + CELL_GAP,
                                                                              200, TITLE_LABEL_HEIGHT)];
            applaudLabel.text = @"Applaud me";
            applaudLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
            [cell.contentView addSubview:applaudLabel];
            return cell;
        }
        
        // Label for the respective rated dimension title
        UILabel *ratedDimensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING,
                                                                                 CELL_PADDING,
                                                                                 self.tableView.frame.size.width/2
                                                                                 - CELL_PADDING - VIEW_PADDING,
                                                                                 TITLE_LABEL_HEIGHT)];
        ratedDimensionLabel.text = self.employee.ratingDimensions[indexPath.row-1][@"title"];
        [cell.contentView addSubview:ratedDimensionLabel];
        
        // Add correct widget for this rateddimension
        UIView *responseWidget = nil;
        int responseWidgetTag = [self.employee.ratingDimensions[indexPath.row-1][@"id"] intValue];
        CGRect responseFrame = CGRectMake(CELL_PADDING,
                                          CELL_PADDING + TITLE_LABEL_HEIGHT + CELL_ELEMENT_PADDING,
                                          self.tableView.frame.size.width
                                          - 2*CELL_PADDING - 2*VIEW_PADDING,
                                          RATING_FIELD_HEIGHT);
        
        if ( [self.employee.ratingDimensions[indexPath.row-1][@"is_text"] boolValue] ) {
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
            [slider setMaximumValue:5.0f];
            [slider addTarget:self action:@selector(sliderValueChanged:)
               forControlEvents:UIControlEventValueChanged];
            sliderTable[[@(responseWidgetTag) description]] = slider;
            responseWidget = slider;
            
            // Add a label to show value of the slider
            UILabel *sliderValue = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 125 - CELL_PADDING,
                                                                             CELL_PADDING,
                                                                             80,
                                                                             TITLE_LABEL_HEIGHT)];
            sliderValue.textAlignment = UITextAlignmentRight;
            sliderValue.text = NO_RATING_TEXT;
            sliderValue.tag = responseWidgetTag;
            sliderLabelTable[[@(responseWidgetTag) description]] = sliderValue;
            // Add a button to clear the rating, to be activated when the slider has been touched
            UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - CELL_PADDING - 35,
                                                                               CELL_PADDING + 8,
                                                                               16,
                                                                               16)];
            [clearButton setBackgroundImage:[UIImage imageNamed:@"cancelrating"] forState:UIControlStateNormal];
            [clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            clearButton.tag = responseWidgetTag;
            clearButtonTable[[@(responseWidgetTag) description]] = clearButton;
           
            [cell.contentView addSubview:clearButton];
            [cell.contentView addSubview:slider];
            [cell.contentView addSubview:sliderValue];
            
            // Note that the slider is untouched (i.e., inactive)
            activityTable[[@(responseWidgetTag) description]] = @(NO);
        }
        // Set the tag of the widget based on the ID of the RatedDimension
        responseWidget.tag = responseWidgetTag;
        
        [widgetList addObject:responseWidget];
        
        [cell.contentView addSubview:responseWidget];
    }
    
    return cell;
}

#pragma mark -
#pragma mark IBActions

/*
 * This gets called for a clear button pressed.
 */
- (void)clearButtonPressed:(id)sender {
    UIButton *clearButton = (UIButton*)sender;
    UILabel *valueLabel = (UILabel *)sliderLabelTable[[@(clearButton.tag) description]];
    UISlider *slider = (UISlider *)sliderTable[[@(clearButton.tag) description]];
    // Reset the slider
    [slider setValue:0.0f animated:YES];
    // Reset the value label
    [valueLabel setText:NO_RATING_TEXT];
    [valueLabel setTextColor:[UIColor blackColor]];
    
    // Note that the slider is no longer active
    activityTable[[@(valueLabel.tag) description]] = @(NO);
}

/*
 * This gets when when a rating slider is touched
 */
- (void)sliderValueChanged:(id)sender {
    // Set value on corresponding label
    UISlider *slider = (UISlider*)sender;
    UILabel *valueLabel = (UILabel *)sliderLabelTable[[@(slider.tag) description]];
    valueLabel.text = [NSString stringWithFormat:@"%1.1f",slider.value];
    
    // Change text color
    float red = (5.0f - slider.value)/5.0f;
    float green = slider.value/5.6f;
    float blue = 0.0f;
    valueLabel.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];

    // Note that the slider is active
    activityTable[[@(valueLabel.tag) description]] = @(YES);
}

- (void) submitButtonPressed:(UIButton *)sender {
    [self submit];
}

- (void)submit {
    // Basic employee information: first name, last name, id
    // NSDictionary literals are immutable...
    NSMutableDictionary *em = [[NSMutableDictionary alloc] initWithDictionary:
                               @{@"first_name": self.employee.firstName,
                               @"last_name": self.employee.lastName,
                               @"id": @(self.employee.employee_id)}];
    
    // Build dictionary for ratings
    NSMutableDictionary *ratings = [[NSMutableDictionary alloc] init];
    for ( UIView *view in widgetList ) {
        if ( ![self sliderHasValue:(UISlider*)view] )
            continue;
        if([view isKindOfClass:[UISlider class]]){
            UISlider *slider = (UISlider *)view;
            ratings[[@(slider.tag) description]] = @(slider.value*5.0);
        }
        else if([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            ratings[[@(field.tag) description]] = field.text;
        }
    }
    
    // Build the final dictionary to send to the server in JSON
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithDictionary:
                                @{@"employee": em,
                                @"ratings": ratings}];
    
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
    EmployeeListViewController *elvc = parent.viewControllers[0];
    // Are we nulling out the employee view here???
    [elvc.employeeControllers replaceObjectAtIndex:[[elvc.tableView indexPathForSelectedRow] row] withObject:[[NSNull alloc] init]];
    [elvc.tableView deselectRowAtIndexPath:[elvc.tableView indexPathForSelectedRow] animated:NO];
}

# pragma mark -
# pragma mark Other Methods

- (BOOL)sliderHasValue:(UISlider*)slider {
    return [activityTable[[@(slider.tag) description]] boolValue];
}

@end
