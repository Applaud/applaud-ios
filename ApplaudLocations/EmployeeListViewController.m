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

@implementation EmployeeListViewController

@synthesize employeeArray = _employeeArray;
@synthesize tableView = _tableView;
@synthesize navigationController = _navigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom init stuff
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


#pragma mark - Table view data source

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
    EmployeeViewController *evc = [[EmployeeViewController alloc] initWithEmployee:[self.employeeArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:evc animated:YES];
}

#pragma mark -
#pragma mark Other Methods

- (void)getEmployees {
    NSURL *url = [[NSURL alloc] initWithString:@"http://127.0.0.1:8000/employees"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *d, NSError *err) {
                               [self handleEmployeeResponse:response data:d error:err];
                           }];
}

/**
 * This handles the employee data fetched from the server
 */
- (void)handleEmployeeResponse:(NSURLResponse *)response data:(NSData *)d error:(NSError *)err {
    if(err) {
        [[[UIAlertView alloc] initWithTitle:@"Connection error"
                                    message:[[NSString alloc] initWithFormat:@"Couldn't get employee: %@", [err description]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else {
        
        NSError *e = [[NSError alloc] init]; // for debugging, probably not needed anymore
        NSArray *employeeData = [NSJSONSerialization JSONObjectWithData:d
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&e];
        self.employeeArray = [[NSMutableArray alloc] init];
        
        // employeeArray is a list of dictionaries, each containing information about an employee
        for ( NSDictionary *dict in employeeData ) {
            Employee *e = [[Employee alloc] initWithFirstName:[dict objectForKey:@"first_name"]
                                                     lastName:[dict objectForKey:@"last_name"]
                                                          bio:[dict objectForKey:@"bio"]
                                                        image:[[UIImage alloc] init]
                                                   dimensions:[[dict objectForKey:@"ratings"]
                                                               objectForKey:@"dimensions"]];
            NSLog(@"%@",e);
            
            // employeeArray will hold all the employees
            [self.employeeArray addObject:e];
            
        }
        
        [self.tableView reloadData];
    }
}

@end
