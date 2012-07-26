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
#import "ConnectionManager.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"

@implementation EmployeeListViewController

@synthesize appDelegate = _appDelegate;
@synthesize employeeArray = _employeeArray;
@synthesize tableView = _tableView;
@synthesize navigationController = _navigationController;
@synthesize employeeControllers = _employeeControllers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Employees"];
        _employeeControllers = [[NSMutableArray alloc] init];
        NSLog(@"elvc registering for notification");
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
        self.tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        self.view.opaque = NO;
        self.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self getEmployees];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark - Table view data source/delegation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.employeeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( nil == cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    [cell.textLabel setText:[[self.employeeArray objectAtIndex:indexPath.row] description]];
    cell.contentView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    cell.textLabel.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    cell.detailTextLabel.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    [cell.imageView setImageWithURL:[(Employee*)[self.employeeArray objectAtIndex:indexPath.row] imageURL]
                   placeholderImage:[UIImage imageNamed:@"blankPerson.jpg"]];
    tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Employee *employee = [self.employeeArray objectAtIndex:indexPath.row];
    EmployeeViewController *evc;
    if([[self.employeeControllers objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
        evc = [[EmployeeViewController alloc] initWithEmployee:employee];
        evc.appDelegate = self.appDelegate;
        [self.employeeControllers replaceObjectAtIndex:indexPath.row withObject:evc];
        evc.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
        evc.title = [NSString stringWithFormat:@"%@ %@",employee.firstName,employee.lastName];
    }
    else {
        evc = [self.employeeControllers objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:evc animated:YES];
}

#pragma mark -
#pragma mark Other Methods

- (void)getEmployees {
    NSArray *keyArray = [[NSArray alloc] initWithObjects:@"goog_id", nil];
    NSArray *valArray = [[NSArray alloc] initWithObjects:self.appDelegate.currentBusiness.goog_id, nil];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:valArray forKeys:keyArray];
    [ConnectionManager serverRequest:@"POST" withParams:dict url:EMPLOYEES_URL callback:^(NSData *dat) {
        NSLog(@"Employee JSON object is......");
        NSLog(@"%@", [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding]);
        NSError *err = [[NSError alloc] init]; // for debugging, probably not needed anymore
        NSArray *employeeData = [NSJSONSerialization JSONObjectWithData:dat
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&err];
        self.employeeArray = [[NSMutableArray alloc] init];
        
        // employeeArray is a list of dictionaries, each containing information about an employee
        for ( NSDictionary *dict in employeeData ) {
            NSLog(@"Employee with id:%d",(int)[[dict objectForKey:@"id"] intValue]);
            NSString *imageURLString = @"";
            if ( ![[dict objectForKey:@"image"] isEqualToString:@""] ) {
                imageURLString = [[NSString alloc] initWithFormat:@"%@%@",
                                  SERVER_URL, [dict objectForKey:@"image"]];
            }
            //TODO: cache images
            Employee *e = [[Employee alloc] initWithFirstName:[dict objectForKey:@"first_name"]
                                                     lastName:[dict objectForKey:@"last_name"]
                                                          bio:[dict objectForKey:@"bio"]
                                                     imageURL:[[NSURL alloc] initWithString:imageURLString]
                                                 profileTitle:[[dict objectForKey:@"ratings"]
                                                               objectForKey:@"rating_title"]
                                                   dimensions:[[dict objectForKey:@"ratings"]
                                                               objectForKey:@"dimensions"]
                                                  employee_id:[[dict objectForKey:@"id"] intValue]];
            NSLog(@"Employee image:%@",e.imageURL);
            // employeeArray will hold all the employees
            [self.employeeArray addObject:e];
            
        }
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
