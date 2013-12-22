//
//  ASHEditRecipeViewController.m
//  C-41
//
//  Created by Ash Furrow on 12/22/2013.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "ASHEditRecipeViewController.h"

// View Model
#import "ASHEditRecipeViewModel.h"

enum {
    ASHEditRecipeViewControllerMetadataSection = 0,
    ASHEditRecipeViewControllerFilmTypeSection,
    ASHEditRecipeViewControllerStepsSection,
    ASHEditRecipeViewControllerNumberOfSections
};

@interface ASHEditRecipeViewController ()

@end

@implementation ASHEditRecipeViewController

static NSString *TitleCellIdentifier = @"title";
static NSString *DescriptionCellIdentifier = @"description";
static NSString *StepCellIdentifier = @"step";
static NSString *AddStepCellIdentifier = @"addStep";
static NSString *FilmTypeCellIdentifier = @"filmType";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.editing = YES;
    
    if ([self.viewModel shouldShowCancelButton] == NO) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    // ReactiveCocoa Bindings
    RAC(self, title) = RACObserve(self.viewModel, name);
    
}

#pragma mark - User Interaction

-(IBAction)cancelWasPressed:(id)sender {
    [self.viewModel cancel];
    [self dismissSelf];
}

-(IBAction)doneWasPressed:(id)sender {
    [self dismissSelf];
}

#pragma mark - Private Methods

-(void)dismissSelf {
    [self.viewModel willDismiss];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return ASHEditRecipeViewControllerNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == ASHEditRecipeViewControllerMetadataSection) {
        return 2;
    } else if (section == ASHEditRecipeViewControllerFilmTypeSection) {
        return 3;
    } else if (section == ASHEditRecipeViewControllerStepsSection) {
        return [self.viewModel numberOfSteps] + 1; //+1 for "add" row
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if (indexPath.section == ASHEditRecipeViewControllerMetadataSection) {
        if (indexPath.row == 0) {
            cellIdentifier = TitleCellIdentifier;
        } else {
            cellIdentifier = DescriptionCellIdentifier;
        }
    } else if (indexPath.section == ASHEditRecipeViewControllerFilmTypeSection) {
        cellIdentifier = FilmTypeCellIdentifier;
    } else {
        if (indexPath.row == [self.viewModel numberOfSteps]) {
            cellIdentifier = AddStepCellIdentifier;
        } else {
            cellIdentifier = StepCellIdentifier;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == ASHEditRecipeViewControllerMetadataSection) {
        return nil;
    } else if (section == ASHEditRecipeViewControllerFilmTypeSection) {
        return NSLocalizedString(@"Film Type", @"Edit View Controller section title");
    } else if (section == ASHEditRecipeViewControllerStepsSection) {
        return NSLocalizedString(@"Steps", @"Edit View Controller section title");
    } else {
        return nil;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == ASHEditRecipeViewControllerStepsSection) {
        return YES;
    } else {
        return NO;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ASHEditRecipeViewControllerStepsSection) {
        if (indexPath.row == [self.viewModel numberOfSteps]) {
            return UITableViewCellEditingStyleInsert;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

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

@end