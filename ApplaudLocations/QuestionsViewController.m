//
//  QuestionsViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "QuestionsViewController.h"
#import "SurveyAccordionCell.h"

@interface QuestionsViewController ()

@end

@implementation QuestionsViewController
@synthesize appDelegate = _appDelegate;
@synthesize survey = _survey;
@synthesize surveyControllers = _surveyControllers; // For caching SurveyFieldViewControllers.
@synthesize summaryText = _summaryText;
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
        self.summaryText.opaque = NO;
        self.summaryText.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        self.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        NSLog(@"color!: %@", self.appDelegate.currentBusiness.primaryColor);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.summaryText.text = self.survey.summary;
	if(nil == _survey) {
        [self getSurveys];
	}
}

- (void)viewDidUnload
{
    [self setSummaryText:nil];
    [self setQuestionsTable:nil];
    [self setNavigationController:nil];
    questionSelections = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table View data source methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.survey.fields count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.questionsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( nil == cell ) {
        cell = [[SurveyAccordionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier
                                                    field:[self.survey.fields objectAtIndex:indexPath.section]];
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
//        return origSize.height * 3 + 2*CELL_PADDING;
        return [[questionSelections objectAtIndex:indexPath.section] floatValue];
    }
    // Showing just the title and whether or not the question has been answered
    else {
        return origSize.height + 2*CELL_PADDING;
    }
}

/*
 * This lets us change the background color of a cell -- if we have a view controller stored at that index and it has an answer, then we set it to green.
 */
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if([[self.surveyControllers objectAtIndex:indexPath.section] isKindOfClass:[SurveyFieldViewController class]] &&
//       [(SurveyFieldViewController *)[self.surveyControllers objectAtIndex:indexPath.section] getAnswer].count &&
//       ![[[(SurveyFieldViewController *)[self.surveyControllers objectAtIndex:indexPath.section] getAnswer] objectAtIndex:0] isEqualToString:@""]) {
//       // cell.backgroundColor = [UIColor greenColor];
//    }
//    // If it's not a survey with an answer, make sure it's reset to white and that its subtitle is "unanswered".
//    else {
//        cell.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
//        cell.detailTextLabel.text = @"Unanswered";
//        cell.detailTextLabel.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
//        cell.textLabel.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
//    }
    
    // Set color and masking
    SurveyAccordionCell *accordionCell = (SurveyAccordionCell*)cell;
    [accordionCell.containerView.layer setMasksToBounds:YES];
    [accordionCell.contentView setBackgroundColor:[UIColor whiteColor]];
    [accordionCell setBackgroundColor:[UIColor whiteColor]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Collapse all questions
    for ( int i=0; i<self.survey.fields.count; i++ ){
        [questionSelections replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        SurveyAccordionCell *cell = (SurveyAccordionCell*)[self.questionsTable 
                                                           cellForRowAtIndexPath:
                                                           [NSIndexPath indexPathForRow:0 
                                                                              inSection:i]];
        [cell contract];
    }
    
    // Note selected state of currently selected question by putting adjusted height (expanded height)
    // into the questinoSelections array.
    [questionSelections replaceObjectAtIndex:indexPath.section 
                                  withObject:[NSNumber numberWithFloat:[(SurveyAccordionCell*)[self.questionsTable cellForRowAtIndexPath:indexPath] adjustedHeight]]];
   
    // Set selection state of cell to "NO"
    [self.questionsTable deselectRowAtIndexPath:indexPath animated:YES];

    // Perform animation
    [self.questionsTable beginUpdates];
    [self.questionsTable endUpdates];
    
    // Show question body
    SurveyAccordionCell *cell = (SurveyAccordionCell*)[self.questionsTable 
                                                       cellForRowAtIndexPath:indexPath];
    [cell expand];
    // Refresh drop-shadows
    for (int i=0; i<self.survey.fields.count; i++) {
        SurveyAccordionCell *cell = (SurveyAccordionCell*)[self.questionsTable 
                                                           cellForRowAtIndexPath:
                                                           [NSIndexPath indexPathForRow:0 
                                                                              inSection:i]];
        [cell.contentView.layer setShadowPath:
         [[UIBezierPath bezierPathWithRoundedRect:cell.contentView.bounds
                                     cornerRadius:5.0f] CGPath]];
        [cell.contentView setNeedsDisplay];
    }
//    SurveyFieldViewController *sfvc;
//    if([[self.surveyControllers objectAtIndex:indexPath.section] isKindOfClass:[NSNull class]]) {
//        sfvc = [[SurveyFieldViewController alloc] initWithNibName:@"SurveyFieldViewController" bundle:nil];
//        sfvc.field = [self.survey.fields objectAtIndex:indexPath.section];
//        [self.surveyControllers replaceObjectAtIndex:indexPath.section withObject:sfvc];
//        // Give the SurveyViewController the right background color.
//        sfvc.view.opaque = YES;
//        sfvc.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
//    }
//    else {
//        sfvc = [self.surveyControllers objectAtIndex:indexPath.section];
//    }
//    [self.navigationController pushViewController:sfvc animated:YES];
}

#pragma mark -
#pragma mark Other Methods

-(void)getSurveys {
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[NSNumber numberWithInt:self.appDelegate.currentBusiness.business_id],
                          @"business_id",
                          nil];
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
    NSLog(@"%@", [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]);
    NSError *e = [[NSError alloc] init];
    NSDictionary *surveyData = [NSJSONSerialization JSONObjectWithData:d
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&e];
    
    // Creating the fields of the survey
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in [surveyData objectForKey:@"questions"]) {
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
                                                    required:NO
                                                          id:[[dict objectForKey:@"id"] intValue]
                                                        type:widgetType
                                                     options:[dict objectForKey:@"options"]
                           ];
        [fields addObject:sf];
    }   

    // Creating the survey model
    Survey *survey = [[Survey alloc] initWithTitle:[surveyData objectForKey:@"title"]
                                           summary:[surveyData objectForKey:@"description"]
                                       business_id:self.appDelegate.currentBusiness.business_id
                                            fields:fields];

    // Setting up the rest of the view: survey, title, submit button
    self.survey = survey;
    [self.questionsTable reloadData];
    self.summaryText.text = self.survey.summary;
    [[self navigationItem] setTitle:self.survey.title];
    
    UIBarButtonItem *submitButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(buttonPressed)];
    submitButtonItem.tintColor = self.appDelegate.currentBusiness.secondaryColor;
//    submitButtonItem.
    [[self navigationItem] setRightBarButtonItem:submitButtonItem];
    int i;
    for(i = 0; i < self.survey.answers.count; i++) {
        [_surveyControllers addObject:[[NSNull alloc] init]];
    }
    
    // Set up selection array
    questionSelections = [[NSMutableArray alloc] init];
    for ( int i=0; i<survey.fields.count; i++ ){ 
        [questionSelections addObject:[NSNumber numberWithBool:NO]];
    }
}

/*
 * Make sure we've answered all the questions.
 */
- (BOOL)checkAnswers {
    for(id object in self.survey.answers) {
        if([object isKindOfClass:[NSNull class]]) {
            return NO;
        }
    }
    return YES;
}

/*
 * Sends our survey data to the server.
 */
- (void)buttonPressed {
    if([self checkAnswers]) {
        NSMutableArray *answers = [[NSMutableArray alloc] init];
        // Grab the data, put it in dictionaries and array for JSON.
        int i;
        for(i = 0; i < self.survey.fields.count; i++) {
            NSDictionary *responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:[self.survey.answers objectAtIndex:i],
                                          @"response",
                                          [[self.survey.fields objectAtIndex:i] label],
                                          @"label",
                                          [NSNumber numberWithInt:[[self.survey.fields objectAtIndex:i] id]],
                                          @"id",
                                          nil];
            [answers addObject:responseDict];
        }
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:answers, @"answers", nil];
        [ConnectionManager serverRequest:@"POST"
                              withParams:params
                                     url:RESPONSE_URL
                                callback:^(NSData *data) {
                                    // Reset all the questions and change to the news feed.
                                    int i;
                                    for(i = 0; i < self.surveyControllers.count; i++) {
                                        [self.surveyControllers replaceObjectAtIndex:i withObject:[[NSNull alloc] init]];
                                    }
                                    [self.questionsTable reloadData];
                                }];
        [[[UIAlertView alloc] initWithTitle:@"Thanks!"
                                    message:@"We appreciate your feedback."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Alert!"
                                    message:@"You should answer all the questions."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
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
