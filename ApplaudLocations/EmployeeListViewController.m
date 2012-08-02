//
//  EmployeeListViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 6/16/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "EmployeeListViewController.h"
#import "EmployeeViewController.h"
#import "Employee.h"
#import "EmployeeDisplayConstants.h"
#import "ConnectionManager.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"

#define NO_EMPLOYEES_MESSAGE @"This business hasn't added any employees yet. Check back later!"
#define GENERIC_MESSAGE [NSString stringWithFormat:@"%@%@%@\n\n%@",@"Applaud is the employee evaluation feature of Apatapa. Applaud allows employees to gain recognition for their hard work. By telling ",self.appDelegate.currentBusiness.name,@" to use this feature, you are playing an important part in giving employees more control over their future.",@"If you are interested in helping this business improve, check out the Feedback button below!"]

@implementation EmployeeListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Employees"];
        _employeeControllers = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:@"BUSINESS_SET"
                                                   object:nil];
    }
    return self;
}

-(void)notificationReceived:(NSNotification *)notification {
    if([notification.name isEqualToString:@"BUSINESS_SET"]) {
        [self getEmployees];
        self.navigationController.navigationBar.tintColor = self.appDelegate.currentBusiness.primaryColor;
        self.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    }
}

-(void)backButtonPressed {
    [self.appDelegate backButtonPressed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonPressed)];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma mark Table view data source/delegation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.employeeArray.count == 0) {
        return 1;
    }
    return self.employeeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellDefaultIdentifier = @"EmployeeCell";
    NSString *cellIdentifier = nil;
    NSString *employeeName = nil;
    if ( self.employeeArray.count == 0 )
        cellIdentifier = cellDefaultIdentifier;
    else {
        employeeName = [self.employeeArray[indexPath.row] description];
        cellIdentifier = employeeName;
    }
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( nil == cell ) {
        cell = [[EmployeeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
        // Configure the cell...
        if ( self.appDelegate.currentBusiness.generic ) {
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = GENERIC_MESSAGE;
            cell.textLabel.font = [UIFont systemFontOfSize:CONTENT_SIZE];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        else if(self.employeeArray.count == 0) {
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = NO_EMPLOYEES_MESSAGE;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        }
        else {
            [cell.textLabel setText:[self.employeeArray[indexPath.row] description]];
            [cell.imageView setImageWithURL:[(Employee*)self.employeeArray[indexPath.row] imageURL]
                           placeholderImage:[UIImage imageNamed:@"blankPerson.jpg"]];
            cell.imageView.layer.cornerRadius = 7.0f;
            cell.imageView.layer.masksToBounds = YES;
            tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:TITLE_SIZE];
        }
    }
    
    return cell;
}

// If it's NO_EMPLOYEES_MESSAGE, return an appropriate size. Else return the default.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( self.appDelegate.currentBusiness.generic ) {
        NSString *genericString = GENERIC_MESSAGE;
        return 2*CELL_PADDING + [genericString sizeWithFont:[UIFont systemFontOfSize:CONTENT_SIZE]
                                          constrainedToSize:CGSizeMake(self.view.frame.size.width - 2*CELL_MARGIN - 2*CELL_PADDING, 400)
                                              lineBreakMode:UILineBreakModeWordWrap].height;
    }
    else if (self.employeeArray.count == 0 && indexPath.row == 0) {
        return 100;
    }
    else return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.employeeArray.count == 0) {
        // Don't do anything.
        return;
    }
    Employee *employee = self.employeeArray[indexPath.row];
    EmployeeViewController *evc;
    if([[self.employeeControllers objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
        evc = [[EmployeeViewController alloc] initWithEmployee:employee];
        evc.appDelegate = self.appDelegate;
        self.employeeControllers[indexPath.row] = evc;
        evc.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        evc.title = [NSString stringWithFormat:@"%@ %@",employee.firstName,employee.lastName];
    }
    else {
        evc = self.employeeControllers[indexPath.row];
    }
    [self.navigationController pushViewController:evc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set shape and color
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 7.0f;
    
    // Some nice visual FX
    cell.contentView.layer.shadowRadius = 5.0f;
    cell.contentView.layer.shadowOpacity = 0.1f;
    cell.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    cell.contentView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,
                                                                                            0,
                                                                                            cell.frame.size.width,
                                                                                            cell.frame.size.height)
                                                                    cornerRadius:7.0f] CGPath];
}

#pragma mark -
#pragma mark Other Methods

- (void)getEmployees {
    NSDictionary *dict = @{@"business_id": @(self.appDelegate.currentBusiness.business_id)};
    [ConnectionManager serverRequest:@"POST" withParams:dict url:EMPLOYEES_URL callback:^(NSHTTPURLResponse *r, NSData *dat) {
        NSLog(@"Employee JSON object is......");
        NSError *err = [[NSError alloc] init]; // for debugging, probably not needed anymore
        NSArray *employeeData = [NSJSONSerialization JSONObjectWithData:dat
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&err];
        self.employeeArray = [[NSMutableArray alloc] init];
        
        // employeeArray is a list of dictionaries, each containing information about an employee
        for ( NSDictionary *dict in employeeData ) {
            NSString *imageURLString = @"";
            if ( ![dict[@"image"] isEqualToString:@""] ) {
                imageURLString = [[NSString alloc] initWithFormat:@"%@%@",
                                  SERVER_URL, dict[@"image"]];
            }
            //TODO: cache images
            Employee *e = [[Employee alloc] initWithFirstName:dict[@"first_name"]
                                                     lastName:dict[@"last_name"]
                                                          bio:dict[@"bio"]
                                                     imageURL:[[NSURL alloc] initWithString:imageURLString]
                                                 profileTitle:dict[@"ratings"][@"rating_title"]
                                                   dimensions:dict[@"ratings"][@"dimensions"]
                                                  employee_id:[dict[@"id"] intValue]];
            // employeeArray will hold all the employees
            [self.employeeArray addObject:e];
            
        }
        // Alphabetize the employees.
        [self.employeeArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Employee *emp1 = (Employee *)obj1;
            Employee *emp2 = (Employee *)obj2;
            // If first name is the same, sort by last name.
            NSComparisonResult firstComparison = [emp1.firstName compare:emp2.firstName];
            if(firstComparison == NSOrderedSame) {
                return [emp1.lastName compare:emp2.lastName];
            }
            return firstComparison;
        }];
        
        // set up our array of view controllers with NSNulls, so that we know whether or not we have one cached for a particular employee        
        int i;
        for(i = 0; i < self.employeeArray.count; i++) {
            [self.employeeControllers addObject:[[NSNull alloc] init]];
        }
        // reload the table view to display all the employees
        [self.tableView reloadData];
    }];
}

@end
