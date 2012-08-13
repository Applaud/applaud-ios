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
#import "EmployeeDisplayConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation EmployeeViewController

- (id)initWithStyle:(UITableViewStyle)style employee:(Employee *)e {
    if ( self = [super initWithStyle:style] ) {
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
  
   
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:self.view.window];
    self.tableView.rowHeight = 2*CELL_PADDING + TITLE_LABEL_HEIGHT + RATING_FIELD_HEIGHT + CELL_ELEMENT_PADDING;
}

- (void)viewDidUnload
{
    [self setNameLabel:nil];
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
    self.nameLabel.frame = CGRectMake(VIEW_PADDING + self.image.frame.size.width + VIEW_ELEMENT_PADDING,
                                      VIEW_PADDING, 150.0f, 24.0f);
    
    // Set up the employee's title label
    [self.titleLabel setText:self.employee.ratingProfileTitle];
    self.titleLabel.frame = CGRectMake(VIEW_PADDING + self.image.frame.size.width + VIEW_ELEMENT_PADDING,
                                       self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height +   VIEW_ELEMENT_PADDING,
                                       150.0f, 24.0f);
    
    // Set up bio labels
    if (self.employee.bio.length > 0 ) {
        // Label "Bio:"
        
        // Bio content label
        [self.bioContentLabel setText:self.employee.bio];
        self.bioContentLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.bioContentLabel.numberOfLines = 0;
        [self.bioContentLabel setFont:[UIFont systemFontOfSize:BIO_SIZE]];
        
        CGSize bioConstraintSize = CGSizeMake(self.view.frame.size.width - 2*CELL_PADDING - 2*VIEW_PADDING, 200.0f);
        NSString *bioText = self.employee.bio;
        CGSize bioSize = [bioText sizeWithFont:[UIFont systemFontOfSize:BIO_SIZE] constrainedToSize:bioConstraintSize lineBreakMode:UILineBreakModeWordWrap];
        CGRect bioTextRect = self.bioContentLabel.frame;
        bioTextRect.size.width = bioConstraintSize.width;
        bioTextRect.size.height = bioSize.height;
        bioTextRect.origin.x = VIEW_PADDING;
        bioTextRect.origin.y = imageRect.origin.y + imageRect.size.height + VIEW_ELEMENT_PADDING;
        self.bioContentLabel.frame = bioTextRect;

    }

    // Make a submit button on the navigation bar
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(submit)];
    [[self navigationItem] setRightBarButtonItem:submitItem];
    
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
    previousOffset = [self.tableView contentOffset];
    
//    UITableViewCell *cell = textField
}

#pragma mark -
#pragma mark Keyboard Handling

- (void)keyboardWillHide:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // resize the scrollview
    CGRect viewFrame = self.view.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height += keyboardSize.height - NAVBAR_SIZE;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [UIView setAnimationDuration:SCROLL_TIME];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
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
    
    // resize the noteView
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height -= keyboardSize.height - NAVBAR_SIZE;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [UIView setAnimationDuration:SCROLL_TIME];
    [self.tableView setFrame:viewFrame];
    [UIView commitAnimations];
    
    CGRect scrollToRect = selectedTextRect;
    scrollToRect.size.height += CELL_PADDING;
    [self.tableView scrollRectToVisible:scrollToRect animated:YES];
  
    keyboardIsShown = YES;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        CGSize bioConstraintSize = CGSizeMake(self.view.frame.size.width - 2*CELL_PADDING - 2*VIEW_PADDING, 200.0f);
        NSString *bioText = self.employee.bio;
        CGSize bioSize = [bioText sizeWithFont:[UIFont systemFontOfSize:BIO_SIZE] constrainedToSize:bioConstraintSize lineBreakMode:UILineBreakModeWordWrap];
        return bioSize.height+IMAGE_SIZE+2*CELL_PADDING+CELL_ELEMENT_PADDING;
        
    }
    return 2*CELL_PADDING + TITLE_LABEL_HEIGHT + RATING_FIELD_HEIGHT + CELL_ELEMENT_PADDING;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.contentView.layer setMasksToBounds:YES];
    
    // Set shape and color
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 7.0f;
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 ) {
        return 1;
    }
    else {
        // Include an empty cell at the top for looks (hide under name tag)
        return self.employee.ratingDimensions.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Ratings section
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        static NSString *namecardCellIdentifier = @"EmployeeNamecardCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:namecardCellIdentifier];
        if (nil == cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:namecardCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.nameLabel = [UILabel new];
            self.titleLabel = [UILabel new];
            self.bioContentLabel = [UILabel new];
            _image = [[UIImageView alloc] initWithImage:nil];
            __weak EmployeeViewController *weakSelf = self;
            [self.image setImageWithURL:self.employee.imageURL
                                success:^(UIImage *img) {
                                    
                                    [weakSelf loadViewWithImage:img];
                                } failure:^(NSError *error) {
                                    [weakSelf loadViewWithImage:[UIImage imageNamed:@"blankPerson.jpg"]];
                                }];
            [cell.contentView addSubview:self.nameLabel];
            [cell.contentView addSubview:self.titleLabel];
            [cell.contentView addSubview:self.bioContentLabel];
            [cell.contentView addSubview:self.image];
            
            
        }
        return cell;
        
    }
    
    else {
        NSString *cellIdentifier = [NSString stringWithFormat:@"EmployeeViewCell%d",[self.employee.ratingDimensions[indexPath.row][@"id"] intValue]];
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if ( nil == cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // Label for the respective rated dimension title
            // If it's a text label, we can use more space horizontally
            UILabel *ratedDimensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING,
                                                                                     CELL_PADDING,
                                                                                     [self.employee.ratingDimensions[indexPath.row][@"is_text"] boolValue] ?
                                                                                     self.tableView.frame.size.width - 2*CELL_PADDING :
                                                                                     9*self.tableView.frame.size.width/16
                                                                                     - CELL_PADDING - VIEW_PADDING,
                                                                                     TITLE_LABEL_HEIGHT)];
            ratedDimensionLabel.text = self.employee.ratingDimensions[indexPath.row][@"title"];
            [cell.contentView addSubview:ratedDimensionLabel];
            
            // Add correct widget for this rateddimension
            UIView *responseWidget = nil;
            int responseWidgetTag = [self.employee.ratingDimensions[indexPath.row][@"id"] intValue];
            CGRect responseFrame = CGRectMake(CELL_PADDING,
                                              CELL_PADDING + TITLE_LABEL_HEIGHT + CELL_ELEMENT_PADDING,
                                              self.tableView.frame.size.width
                                              - 2*CELL_PADDING - 2*VIEW_PADDING,
                                              RATING_FIELD_HEIGHT);
            
            if ( [self.employee.ratingDimensions[indexPath.row][@"is_text"] boolValue] ) {
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
                UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - CELL_PADDING - 43,
                                                                                   CELL_PADDING,
                                                                                   32,
                                                                                   32)];
                [clearButton setImage:[UIImage imageNamed:@"cancelrating"] forState:UIControlStateNormal];
                [clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                clearButton.tag = responseWidgetTag;
                clearButtonTable[[@(responseWidgetTag) description]] = clearButton;
                // Make the clear button invisible at first, to appear when the slider is moved.
                [clearButton setUserInteractionEnabled:NO];
                [clearButton setHidden:YES];
                
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
    
    // Hide the button
    clearButton.userInteractionEnabled = NO;
    clearButton.hidden = YES;
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
    
    // Show the "cancel rating" button
    UIButton *clearButton = nil;
    for ( UIView *subview in slider.superview.subviews ) {
        if ( [subview isKindOfClass:[UIButton class]] )
            clearButton = (UIButton*)subview;
    }
    [clearButton setUserInteractionEnabled:YES];
    [clearButton setHidden:NO];
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
        if([view isKindOfClass:[UISlider class]]){
            if ( ![self sliderHasValue:(UISlider*)view] )
                continue;
            UISlider *slider = (UISlider *)view;
            ratings[[@(slider.tag) description]] = @(slider.value*5.0);
        }
        else if([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            if(field.text)
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
    
