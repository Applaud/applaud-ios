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
@synthesize survey = _survey;
@synthesize titleLabel = _titleLabel;
@synthesize summaryText = _summaryText;
@synthesize questionsTable = _questionsTable;
@synthesize navigationController = _navigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
/*        SurveyField *sf1 = [[SurveyField alloc] initWithLabel:@"q1" required:YES id:1 type:DROPDOWN options:nil];
        SurveyField *sf2 = [[SurveyField alloc] initWithLabel:@"q2" required:YES id:2 type:CHECKBOX options:nil];
        _survey = [[Survey alloc] initWithTitle:@"Survey" summary:@"test survey" fields:[[NSMutableArray alloc]
                                                                                         initWithObjects:sf1, sf2, nil]];*/
    }
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    SurveyField *field = [self.survey.fields objectAtIndex:indexPath.row];
    cell.textLabel.text = field.label;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // ¿Should write a SurveyFieldViewController first?
    SurveyFieldViewController *sfvc = [[SurveyFieldViewController alloc] init];
    sfvc.field = [self.survey.fields objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:sfvc animated:YES];
}

#pragma mark -
#pragma Other Methods
-(void)getSurveys {
    NSURL *url = [[NSURL alloc] initWithString:@"http://127.0.0.1:8000/get_survey"];
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
                                                                           fields:fields];
                                   self.survey = survey;
                                   [self.questionsTable reloadData];
                                   self.summaryText.text = self.survey.summary;
                                   self.titleLabel.text = self.survey.title;
                               }
                           }];
}
@end
