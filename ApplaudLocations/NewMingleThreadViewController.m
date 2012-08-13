//
//  NewMingleThreadViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/9/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NewMingleThreadViewController.h"
#import "MingleListViewController.h"
#import "NewMingleThreadCell.h"
#import "ConnectionManager.h"
#import "UIViewController+KeyboardDismiss.h"

@interface NewMingleThreadViewController ()

@end

@implementation NewMingleThreadViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initForKeyboardDismissal];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set our title
    self.title = @"New Thread";
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setEditing:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    if ( self.editing )
        [[(NewMingleThreadCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField] becomeFirstResponder];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated {
    if ( self.editing )
        [self setEditing:NO animated:YES];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.navigationItem setHidesBackButton:editing animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Thread title section, submit/cancel
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Title field
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *SubmitCancelID = @"SubmitCancelCell";
    
    if ( indexPath.section == 1 ) {
        SubmitCancelCell *submitCancel = [tableView dequeueReusableCellWithIdentifier:SubmitCancelID];
        if ( nil == submitCancel ) {
            submitCancel = [[SubmitCancelCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:SubmitCancelID];
            submitCancel.delegate = self;
        }
        return submitCancel;
    }
    
    NewMingleThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( nil == cell ){
        cell = [[NewMingleThreadCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        cell.placeholder = @"Thread Title";
        cell.textField.delegate = self;
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ( section == 0 ) {
        return @"Thread Title";
    }
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - SubmitCancelDelegate

-(void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)submitButtonPressed {
    NewMingleThreadCell *cell = (NewMingleThreadCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *title = cell.textField.text;
    
    if ( [title length] == 0 ) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid Thread"
                                    message:@"Threads must have a title."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else {
        [self submitThread];
    }
}

#pragma mark - Submit Thread

-(void)submitThread {
    NewMingleThreadCell *cell = (NewMingleThreadCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *title = cell.textField.text;
    
    if ( [title length] > 0 ) {
        // Save thread
        NSDictionary *params = @{ @"business_id" : @(self.parent.appDelegate.currentBusiness.business_id),
        @"title" : title};
        [ConnectionManager serverRequest:@"POST"
                              withParams:params
                                     url:THREAD_CREATE_URL
                                callback:^(NSHTTPURLResponse *response, NSData *data) {
                                    [self.parent getThreads];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }];
    }
}

@end
