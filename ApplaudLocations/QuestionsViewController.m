//
//  QuestionsViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "QuestionsViewController.h"
#import "SurveyDisplayConstants.h"
#import "SurveyAccordionCell.h"

@implementation QuestionsViewController

@synthesize appDelegate = _appDelegate;
@synthesize survey = _survey;
@synthesize surveyControllers = _surveyControllers; // For caching SurveyFieldViewControllers.
@synthesize questionsTable = _questionsTable;
@synthesize navigationController = _navigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _surveyControllers = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:@"BUSINESS_SET"
                                                   object:nil];
    }
    return self;
}

-(void)notificationReceived:(NSNotification *)notification {
    if([notification.name isEqualToString:@"BUSINESS_SET"]) {
        [self getSurveys];
        self.view.opaque = YES;
        self.navigationController.navigationBar.tintColor = self.appDelegate.currentBusiness.primaryColor;
        self.questionsTable.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        self.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        NSLog(@"color!: %@", self.appDelegate.currentBusiness.primaryColor);
    }
}

-(void)backButtonPressed {
    [self.appDelegate backButtonPressed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	if(nil == _survey) {
        //[self getSurveys];
	}
    
    // Back button.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonPressed)];
    
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
    [self setQuestionsTable:nil];
    [self setNavigationController:nil];
    questionSelections = nil;
    
    // unregister for keyboard notifications while not visible.
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

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//}

#pragma mark -
#pragma mark Table View data source methods

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ( self.survey.fields.count > 0 && section == 0 ) {
        return self.survey.summary;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0f];
    label.text = sectionTitle;
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
    
    CGSize labelSizeConstraint = CGSizeMake(self.view.frame.size.width - 2*CELL_PADDING - 30,
                                            300);
    CGFloat labelHeight = [sectionTitle sizeWithFont:[UIFont systemFontOfSize:14.0f]
                                   constrainedToSize:labelSizeConstraint
                                       lineBreakMode:UILineBreakModeWordWrap].height;
    label.frame = CGRectMake(VIEW_LEFT_PADDING, VIEW_TOP_PADDING, labelSizeConstraint.width, labelHeight);
    label.textAlignment = UITextAlignmentCenter;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] init];
    [view sizeToFit];
    [view addSubview:label];
    
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.survey.fields count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SurveyAccordionCell *cell = [self.questionsTable dequeueReusableCellWithIdentifier:[[self.survey.fields objectAtIndex:indexPath.section] label]];
    
    if ( nil == cell ) {
        cell = [[SurveyAccordionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:[[self.survey.fields objectAtIndex:indexPath.section] label]
                                                    field:[self.survey.fields objectAtIndex:indexPath.section]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ( indexPath.section == 0 ) {
            UIImageView *sytImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shareyourthoughts"]];
            sytImage.frame = CGRectMake(self.view.frame.size.width - CELL_MARGIN - CELL_PADDING - sytImage.frame.size.width,
                                        CELL_PADDING - 3,
                                        sytImage.frame.size.width,
                                        sytImage.frame.size.height);
            [cell.contentView addSubview:sytImage];
            
            [cell expand];
            [cell layoutSubviews];
        }
    }
    return cell;
}

# pragma mark -
# pragma mark UITableViewDelegate methods

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // dumb max height for testing purposes
    int expandedHeight = 400;
    
    // max size for the title label
    CGSize constrainedSize = CGSizeMake(self.view.bounds.size.width
                                        - 2*CELL_MARGIN
                                        - 2*CELL_PADDING, expandedHeight);
    
    
    SurveyField *field = [self.survey.fields objectAtIndex:indexPath.section];
    NSString *questionLabel = field.label;
    
    // original size of the cell
    CGSize origSize = [questionLabel
                       sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE] 
                       constrainedToSize:constrainedSize
                       lineBreakMode:UILineBreakModeWordWrap];
    
    // Showing the content of the question upon selection
    if ( [self cellIsSelectedAtIndexPath:indexPath] ) {
        return [[questionSelections objectAtIndex:indexPath.section] floatValue];
    }
    // Showing just the title and whether or not the question has been answered
    else {
        return origSize.height + 2*CELL_PADDING + 2;
    }
}

/*
 * This lets us change the background color of a cell -- if we have a view controller stored at that index and it has an answer, then we set it to green.
 */
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SurveyAccordionCell *acccell = (SurveyAccordionCell*)cell;
    NSLog(@"Label for cell was %@",acccell.questionLabel.text);
    NSLog(@"Number of cells: %d",self.questionsTable.numberOfSections);
    
    // Set color and shape
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 7.0f;
    cell.contentView.layer.borderWidth = 1.0f;
    cell.contentView.layer.borderColor = [[UIColor grayColor] CGColor];
    [[(SurveyAccordionCell*)cell containerView].layer setMasksToBounds:YES];
    
    // Some nice visual FX
    cell.contentView.layer.shadowRadius = 5.0f;
    cell.contentView.layer.shadowOpacity = 0.2f;
    cell.contentView.layer.shadowOffset = CGSizeMake(1, 0);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SurveyAccordionCell *cell = (SurveyAccordionCell*)[self.questionsTable cellForRowAtIndexPath:indexPath];
    
    // Maintain background color (contentView will go transparent at this point)
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    // Collapse all questions
    for ( int i=0; i<self.survey.fields.count; i++ ){
        SurveyAccordionCell *cell = (SurveyAccordionCell*)[self.questionsTable 
                                                           cellForRowAtIndexPath:
                                                           [NSIndexPath indexPathForRow:0 
                                                                              inSection:i]];
        
        [cell contract];
               
        [questionSelections replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    }
    
    // Note selected state of currently selected question by putting adjusted height (expanded height)
    // into the questionSelections array.
    [questionSelections replaceObjectAtIndex:indexPath.section 
                                  withObject:[NSNumber numberWithFloat:[cell expandedHeight]]];

    // Perform animation
    [self.questionsTable beginUpdates];
    [self.questionsTable endUpdates];
    
    // Show question body
    [cell expand];
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

    [UIView setAnimationDuration:SCROLL_LENGTH];
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
    
    [UIView setAnimationDuration:SCROLL_LENGTH];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    [self.questionsTable scrollToRowAtIndexPath:[self.questionsTable indexPathForSelectedRow]
                               atScrollPosition:UITableViewScrollPositionTop
                                       animated:YES];
    
    keyboardIsShown = YES;
}


#pragma mark -
#pragma mark Other Methods

-(void)getSurveys {
//    NSDictionary *dict = [[NSDictionary alloc]
//                          initWithObjectsAndKeys: self.appDelegate.currentBusiness.goog_id],
//                          @"goog_id",
//                          nil];
    NSArray *keyArray = [[NSArray alloc] initWithObjects:@"business_id", nil];
    NSArray *valArray = [[NSArray alloc] initWithObjects:@(self.appDelegate.currentBusiness.business_id), nil];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:valArray forKeys:keyArray];
                            
    
    [ConnectionManager serverRequest:@"POST"
                            withParams:dict
                                 url:SURVEY_URL
                            callback: ^(NSData *d) {
                                [self handleSurveyData:d];
                            }];
}

/**
 * This handles the response from the server (that is, the received survey in JSON format).
 * 
 * This sets up our view to render all the widgets in the survey, as well as creating a
 * 'submit' button and setting our title.
 */
- (void)handleSurveyData:(NSData *)d {
    // Grabbing the JSON data from the server's response
    NSLog(@"Survey data is......");
    NSLog(@"%@", [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]);
    NSError *e = [[NSError alloc] init];
    NSDictionary *surveyData = [NSJSONSerialization JSONObjectWithData:d
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&e];
    
    // Creating the fields of the survey
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    int genFeedbackIndex = 0;
    for ( int i=0; i<[(NSArray*)[surveyData objectForKey:@"questions"] count]; i++) {
        NSDictionary *dict = [[surveyData objectForKey:@"questions"] objectAtIndex:i];
        
        if ( [[dict objectForKey:@"general_feedback"] boolValue] )
            genFeedbackIndex = i;
        
        NSString *type = [dict objectForKey:@"type"];
        QuestionType widgetType;
        if([type isEqualToString:@"TF"]) {
            widgetType = TEXTFIELD;
        }
        else if([type isEqualToString:@"TA"]) {
            widgetType = TEXTAREA;
        }
        else if([type isEqualToString:@"CG"]) {
            widgetType = CHECKBOX;
        }
        else {
            widgetType = RADIO;
        }
        SurveyField *sf = [[SurveyField alloc] initWithLabel:[dict objectForKey:@"label"]
                                                          id:[[dict objectForKey:@"id"] intValue]
                                                        type:widgetType
                                                     options:[dict objectForKey:@"options"]
                           ];
        [fields addObject:sf];
    }
    SurveyField *temp = [fields objectAtIndex:0];
    [fields setObject:[fields objectAtIndex:genFeedbackIndex] atIndexedSubscript:0];
    [fields setObject:temp atIndexedSubscript:genFeedbackIndex];

    NSLog(@"%@",fields.description);
    
    // Creating the survey model
    Survey *survey = [[Survey alloc] initWithTitle:[surveyData objectForKey:@"title"]
                                           summary:[surveyData objectForKey:@"description"]
                                       business_id:self.appDelegate.currentBusiness.business_id
                                            fields:fields];

    // Setting up the rest of the view: survey, title, submit button
    self.survey = survey;
    [[self navigationItem] setTitle:self.survey.title];
    
    UIBarButtonItem *submitButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(buttonPressed)];
    submitButtonItem.tintColor = self.appDelegate.currentBusiness.primaryColor;

    [[self navigationItem] setRightBarButtonItem:submitButtonItem];
    
    // Set up selection array
    questionSelections = [[NSMutableArray alloc] init];
    for ( int i=0; i<survey.fields.count; i++ ){
        [questionSelections addObject:[NSNumber numberWithBool:NO]];
    }
    // First question is already expanded
    CGFloat genFeedbackLabelHeight = [[[fields objectAtIndex:0] label] sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_SIZE] constrainedToSize:CGSizeMake(self.view.frame.size.width - 2*CELL_MARGIN - 2*CELL_PADDING, 300) lineBreakMode:UILineBreakModeWordWrap].height;
    [questionSelections setObject:[NSNumber numberWithFloat:2*CELL_PADDING + 2*CELL_ELEMENT_PADDING + 2*WIDGET_HEIGHT + genFeedbackLabelHeight]
               atIndexedSubscript:0];
    
    // Load the table
    [self.questionsTable reloadData];
}

/*
 * Sends our survey data to the server.
 */
- (void)buttonPressed {
    NSMutableArray *surveyAnswers = [[NSMutableArray alloc] init];
    for ( int i=0; i<self.survey.fields.count; i++ ) {
        SurveyAccordionCell *cell = (SurveyAccordionCell*)[self.questionsTable cellForRowAtIndexPath:
                                                           [NSIndexPath indexPathForRow:0 inSection:i]];
        NSArray *response = [cell getAnswer];
        if (! response)
            response = [[NSArray alloc] init];
        
        NSDictionary *responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      response, @"response",
                                      [[self.survey.fields objectAtIndex:i] label], @"label",
                                      [NSNumber numberWithInt:[[self.survey.fields objectAtIndex:i] id]], @"id",
                                      nil];
        
        [surveyAnswers addObject:responseDict];
    }
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:surveyAnswers, @"answers", nil];
    
    NSLog(@"Sending these survey responses: %@",params);
    
    [ConnectionManager serverRequest:@"POST"
                          withParams:params
                                 url:RESPONSE_URL
                            callback:^(NSData* dat) {
                                // Collapse all table cells, but retain responses.
                                for (int i=0; i<self.questionsTable.numberOfSections; i++) {
                                    SurveyAccordionCell *cell = (SurveyAccordionCell*)[self.questionsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                                    [cell contract];
                                    [questionSelections replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                                    [self.questionsTable reloadData];
                                }
                            }];
    
    [[[UIAlertView alloc] initWithTitle:@"Thanks!"
                                    message:@"We appreciate your feedback."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
}

/*
 * When the user dismisses the "thanks!" alert view, go to the news feed screen.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController.tabBarController setSelectedIndex:4];
}

- (BOOL)cellIsSelectedAtIndexPath:(NSIndexPath *)indexPath {
    return ![[questionSelections objectAtIndex:indexPath.section] isEqualToNumber:[NSNumber numberWithBool:NO]];
}
@end
