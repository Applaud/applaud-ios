//
//  NewPollViewController.m
//  ApplaudIOS
//
//  Created by Luke Lovett on 8/6/12.
//  Copyright (c) 2012 Applaud, Inc. All rights reserved.
//

#import "NewPollViewController.h"
#import "PollFieldCell.h"
#import "ConnectionManager.h"
#import "PollsViewController.h"

@interface NewPollViewController ()

@end

@implementation NewPollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                      style:UITableViewStyleGrouped];
        self.options = [[NSMutableArray alloc] init];
        self.pollTitle = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add "Done"/"Edit" button
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Clear table background
    UIView *tableBackground = [[UIView alloc] initWithFrame:self.view.frame];
    tableBackground.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    self.tableView.backgroundView = tableBackground;
    self.view.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    self.tableView.backgroundColor = self.appDelegate.currentBusiness.secondaryColor;
    
    // Set our title
    self.title = @"Create a Poll";
    
    // Add submit/cancel button
    UISegmentedControl *submitCancel = [[UISegmentedControl alloc] initWithItems:
                                        [NSArray arrayWithObjects:@"Submit", @"Cancel", nil]];

    [self.view addSubview:submitCancel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setEditing:YES animated:YES];
    
    // Start with two options
    [self insertOptionAnimated:NO];
    [self insertOptionAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Refresh list of polls in PollsViewController
    [self.pollsViewController getPolls];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TitleCellIdentifier = @"TitleCell";
    // Title section
    if ( indexPath.section == 0 ) {
        PollFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if ( nil == cell ) {
            cell = [[PollFieldCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:TitleCellIdentifier];
            cell.placeholder = @"Poll Title";
            cell.textField.delegate = self;
            cell.textField.tag = -1;    // -1 == the title textfield
        }
        return cell;
    }
    
    static NSString *SubmitCancelCellIdentifier = @"SubmitCancelCell";
    // "Submit","Cancel"
    if ( indexPath.section == 2 ) {
        PollSubmitCancelCell *cell = (PollSubmitCancelCell*)[self.tableView dequeueReusableCellWithIdentifier:SubmitCancelCellIdentifier];
        if ( nil == cell ) {
            cell = [[PollSubmitCancelCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:SubmitCancelCellIdentifier];
            cell.delegate = self;
        }
        return cell;
    }
    
    static NSString *InsertCellIdentifier = @"InsertOptionCell";
    static NSString *DeletePollIdentifier = @"DeletePollCell";
    static NSString *CellIdentifier = @"OptionCell";

    // "Add Option"
    if ( indexPath.row == self.options.count ) {
        UITableViewCell *insertCell = [self.tableView dequeueReusableCellWithIdentifier:InsertCellIdentifier];
        if ( nil == insertCell ) {
            insertCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:InsertCellIdentifier];
            insertCell.textLabel.text = @"Add Option";
        }
        insertCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return insertCell;
    }
    // "Delete Poll"
    else if ( indexPath.row == self.options.count + 1 ) {
        UITableViewCell *deleteCell = [self.tableView dequeueReusableCellWithIdentifier:DeletePollIdentifier];
        if ( nil == deleteCell ) {
            deleteCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:DeletePollIdentifier];
            deleteCell.textLabel.text = @"Delete Poll";
        }
        deleteCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return deleteCell;
    }

    // An option
    // for now, return a dumb cell
    PollFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( nil == cell ) {
        cell = [[PollFieldCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:CellIdentifier];
        cell.placeholder = @"Option";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.delegate = self;
        cell.textField.tag = self.options.count -1;    // tag is index of option
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch ( section ) {
        case 0:
            return @"Title";
            break;
        case 1:
            return @"Options";
            break;
    }
    return @"";
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // "Title" section
    if ( 0 == section ) {
        return 1;
    }
    
    // Options, "Add Option", "Remove Poll"
    else if ( 1 == section ) {
        NSUInteger count = self.options.count;
        if (self.editing) {
            return count+2;
        }
        return count;
    }
    
    // "Submit"/"Cancel"
    else if ( 2 == section ) {
        return 1;
    }
    
    return 0;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    // One for the title, one for options/management, one for submit/cancel
    return 3;
}

#pragma mark -
#pragma mark Cell Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do not edit submit/cancel
    if ( indexPath.section == 2 )
        return NO;
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do not indent title cell
    if ( indexPath.section == 0 )
        return NO;
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // No editing icon on "Title"
	if ( indexPath.section == 0 )
        return UITableViewCellEditingStyleNone;
    
	// The add row gets an insertion marker
	if (indexPath.row == self.options.count) {
		return UITableViewCellEditingStyleInsert;
	}
    // Other rows get delete marker
    return UITableViewCellEditingStyleDelete;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];
  
	// Don't show the Back button while editing.
    [self.navigationItem setHidesBackButton:editing animated:YES];
    
	[self.tableView beginUpdates];
 
    NSArray *addButtonIndexPaths = [NSArray arrayWithObjects:
                                    [NSIndexPath indexPathForRow:self.options.count inSection:1],
                                    [NSIndexPath indexPathForRow:self.options.count+1 inSection:1],
                                    nil];
    
	// Add or remove the "Add row"/"Delete poll" buttons as appropriate.
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
	if (editing) {
		if (animated) {
			animationStyle = UITableViewRowAnimationFade;
		}
		[self.tableView insertRowsAtIndexPaths:addButtonIndexPaths withRowAnimation:animationStyle];
	}
	else {
        [self.tableView deleteRowsAtIndexPaths:addButtonIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.options removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
		
    }
	
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		[self insertOptionAnimated:YES];
	}	
}

- (void)insertOptionAnimated:(BOOL)animated {
    [self.options addObject:@""];
    
    // Create a new cell, with optional animation
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.options.count-1 inSection:1];
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
	if (animated) {
		animationStyle = UITableViewRowAnimationFade;
	}
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animationStyle];
	
	// Start editing the option inserted, if animated
    if ( animated ) {
        PollFieldCell *cell = (PollFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Disable selection of the "Add Option"/"Delete Poll" buttons.
	if (indexPath.row >= self.options.count) {
		return nil;
	}
	return indexPath;
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ( textField.tag == -1 ) {
        self.pollTitle = textField.text;
    } else {
        [self.options replaceObjectAtIndex:textField.tag withObject:textField.text];
    }
    
    NSLog(@"Textfield tag was %d",textField.tag);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark SubmitCancelDelegate

- (void)submitButtonPressed {
    // Do some validation
    // Clean out empty strings from options
    NSMutableArray *newOptions = [[NSMutableArray alloc] init];
    for ( NSString *option in self.options ) {
        if (! [option isEqualToString:@""] ) {
            [newOptions addObject:option];
        }
    }
    if ( [self.pollTitle isEqualToString:@""] ) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid Poll"
                                    message:@"You must give your Poll a title."
                                   delegate:self cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    else if ( newOptions.count < 2 ) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid Poll"
                                    message:@"Your Poll must have at least two non-blank options."
                                   delegate:self cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    [self submitPoll];
}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Deselect submit/cancel
    [[(PollSubmitCancelCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] submitCancel] setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

#pragma mark -
#pragma mark Other Methods

- (void)submitPoll {
    
    // Clean out empty strings from options
    NSMutableArray *newOptions = [[NSMutableArray alloc] init];
    for ( NSString *option in self.options ) {
        if (! [option isEqualToString:@""] ) {
            [newOptions addObject:option];
        }
    }
    
    NSDictionary *params = @{ @"title" : self.pollTitle,
    @"options" : newOptions,
    @"business_id" : @(self.appDelegate.currentBusiness.business_id)};
    
    [ConnectionManager serverRequest:@"POST"
                          withParams:params
                                 url:POLL_CREATE_URL
                            callback:^(NSHTTPURLResponse *response, NSData *data) {
                                // Deselect submit/cancel
                                [[(PollSubmitCancelCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] submitCancel] setSelectedSegmentIndex:UISegmentedControlNoSegment];
                                
                                // Handle bad request (means something about the poll was bad)
                                if ( 400 == response.statusCode ) {
                                    NSString *errorMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                    [[[UIAlertView alloc] initWithTitle:@"Invalid Poll"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil] show];
                                }
                                // All went well
                                else if ( 200 == response.statusCode ) {
                                    // Go back
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                            }];
}

@end
