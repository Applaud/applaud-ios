//
//  QuestionsViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/13/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "QuestionsViewController.h"

@interface QuestionsViewController ()

@end

@implementation QuestionsViewController
@synthesize appDelegate = _appDelegate;
@synthesize survey = _survey;
@synthesize surveyControllers = _surveyControllers; // For caching SurveyFieldViewControllers.
@synthesize titleLabel = _titleLabel;
@synthesize summaryText = _summaryText;
@synthesize questionsTable = _questionsTable;
@synthesize navigationController = _navigationController;
@synthesize submitButton = _submitButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _surveyControllers = [[NSMutableArray alloc] init];    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	if(nil == _survey) {
        [self getSurveys];
	}
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setSummaryText:nil];
    [self setQuestionsTable:nil];
    [self setNavigationController:nil];
    [self setSubmitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma Table View data source methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.survey.fields count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.questionsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( nil == cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.text = @"Unanswered";
    }
    SurveyField *field = [self.survey.fields objectAtIndex:indexPath.row];
    cell.textLabel.text = field.label;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", [self.survey.answers objectAtIndex:indexPath.row]);
/*    switch([[self.survey.fields objectAtIndex:indexPath.row] type]) {
        case TEXTAREA:
    }*/
    SurveyFieldViewController *sfvc;
    if([[self.surveyControllers objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
        sfvc = [[SurveyFieldViewController alloc] initWithNibName:@"SurveyFieldViewController" bundle:nil];
        sfvc.field = [self.survey.fields objectAtIndex:indexPath.row];
        [self.surveyControllers replaceObjectAtIndex:indexPath.row withObject:sfvc];
    }
    else {
        sfvc = [self.surveyControllers objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:sfvc animated:YES];
}

#pragma mark -
#pragma Other Methods
-(void)getSurveys {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, @"/get_survey/"];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *d, NSError *err) {
                               if(err) {
                                   [[[UIAlertView alloc] initWithTitle:@"Connection error"
                                                               message:[[NSString alloc] initWithFormat:@"Couldn't get survey: %@", [err description]]
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil] show];
                               }
                               else {
                                   NSError *e = [[NSError alloc] init];
                                   NSDictionary *surveyData = [NSJSONSerialization JSONObjectWithData:d
                                                                                              options:NSJSONReadingAllowFragments
                                                                                                error:&e];
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
                                                                                         id:0
                                                                                       type:widgetType
                                                                                    options:[dict objectForKey:@"options"]
                                                          ];
                                       [fields addObject:sf];
                                   }
                                   Survey *survey = [[Survey alloc] initWithTitle:[surveyData objectForKey:@"title"]
                                                                          summary:[surveyData objectForKey:@"description"]
                                                                               business_id:self.appDelegate.currentBusiness.business_id
                                                                           fields:fields];
                                   self.survey = survey;
                                   [self.questionsTable reloadData];
                                   self.summaryText.text = self.survey.summary;
                                   self.titleLabel.text = self.survey.title;
                                   int i;
                                   for(i = 0; i < self.survey.answers.count; i++) {
                                       [_surveyControllers addObject:[[NSNull alloc] init]];
                                   }
                               }
                           }];
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
- (IBAction)buttonPressed:(UIButton *)sender {
    if([self checkAnswers]) {
        NSMutableArray *answers = [[NSMutableArray alloc] init];
        // Grab the data, put it in dictionaries and array for JSON.
        int i;
        for(i = 0; i < self.survey.fields.count; i++) {
            NSDictionary *responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:[self.survey.answers objectAtIndex:i],
                                          @"response",
                                          [[self.survey.fields objectAtIndex:i] label],
                                          @"label",
                                          nil];
            [answers addObject:responseDict];
        }
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:answers, @"answers", nil];
        [ConnectionManager serverRequest:@"POST"
                              withParams:params
                                     url:@"/survey_respond/"
                                callback:^(NSData *data) {
                                    // Be sure we've posted correctly.
                                    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                }];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Alert!"
                                    message:@"You should answer all the questions."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
@end
