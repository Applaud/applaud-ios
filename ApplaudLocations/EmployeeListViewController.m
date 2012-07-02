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
#import "AppDelegate.h"
//#import <SDWebImage/UIImageView+WebCache.h>

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getEmployees];
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if ( nil == cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    // Configure the cell...
    [cell.textLabel setText:[[self.employeeArray objectAtIndex:indexPath.row] description]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EmployeeViewController *evc;
    if([[self.employeeControllers objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
        evc = [[EmployeeViewController alloc] initWithEmployee:[self.employeeArray objectAtIndex:indexPath.row]];
        evc.appDelegate = self.appDelegate;
        [self.employeeControllers replaceObjectAtIndex:indexPath.row withObject:evc];
    }
    else {
        evc = [self.employeeControllers objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:evc animated:YES];
}

#pragma mark -
#pragma mark Other Methods

- (void)getEmployees {
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[NSNumber numberWithInt:self.appDelegate.currentBusiness.business_id],
                          @"business_id", nil];
    [ConnectionManager serverRequest:@"POST" withParams:dict url:EMPLOYEES_URL callback:^(NSData *dat) {
        NSLog(@"%@", [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding]);
        NSError *err = [[NSError alloc] init]; // for debugging, probably not needed anymore
        NSArray *employeeData = [NSJSONSerialization JSONObjectWithData:dat
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&err];
        self.employeeArray = [[NSMutableArray alloc] init];
        
        // employeeArray is a list of dictionaries, each containing information about an employee
        for ( NSDictionary *dict in employeeData ) {
            
            Employee *e = [[Employee alloc] initWithFirstName:[dict objectForKey:@"first_name"]
                                                     lastName:[dict objectForKey:@"last_name"]
                                                          bio:[dict objectForKey:@"bio"]
                                                        image:[UIImage imageWithData:[NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:[dict objectForKey:@"image"]]]]
                                                   dimensions:[[dict objectForKey:@"ratings"]
                                                               objectForKey:@"dimensions"]
                                                  employee_id:[[dict objectForKey:@"id"] intValue]];
            
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
