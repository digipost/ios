//
//  SHCDocumentsViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCDocumentsViewController.h"
#import "SHCModelManager.h"
#import "SHCDocument.h"
#import "SHCDocumentTableViewCell.h"
#import "SHCAttachment.h"
#import "SHCAPIManager.h"
#import "UIAlertView+Blocks.h"
#import "SHCRootResource.h"
#import "SHCFolder.h"
#import "NSError+ExtraInfo.h"
#import "SHCAttachmentsViewController.h"
#import "SHCLetterViewController.h"
#import "SHCAppDelegate.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushDocumentsIdentifier = @"PushDocuments";

// Google Analytics screen name
NSString *const kDocumentsViewControllerScreenName = @"Documents";

@interface SHCDocumentsViewController ()

@end

@implementation SHCDocumentsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.baseEntity = [[SHCModelManager sharedManager] documentEntity];
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(createdAt))
                                                           ascending:YES
                                                            selector:@selector(compare:)]];
    self.predicate = [NSPredicate predicateWithFormat:@"%K == %@",
                      [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(folder)), NSStringFromSelector(@selector(name))],
                      self.folderName];

    self.screenName = kDocumentsViewControllerScreenName;

    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SHCAPIManager sharedManager] cancelUpdatingDocuments];

    [self programmaticallyEndRefresh];

    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushAttachmentsIdentifier]) {
        SHCDocument *document = (SHCDocument *)sender;

        SHCAttachmentsViewController *attachmentsViewController = (SHCAttachmentsViewController *)segue.destinationViewController;
        attachmentsViewController.attachments = document.attachments;
    } else if ([segue.identifier isEqualToString:kPushLetterIdentifier]) {
        SHCAttachment *attachment = (SHCAttachment *)sender;

        SHCLetterViewController *letterViewController = (SHCLetterViewController *)segue.destinationViewController;
        letterViewController.attachment = attachment;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCDocument *document = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDocumentTableViewCellIdentifier forIndexPath:indexPath];

    SHCAttachment *attachment = [document mainDocumentAttachment];
    cell.textLabel.text = attachment.subject;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCDocument *document = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([document.attachments count] > 1) {
        [self performSegueWithIdentifier:kPushAttachmentsIdentifier sender:document];
    } else {

        SHCAttachment *attachment = [document.attachments firstObject];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = attachment;
        } else {
            [self performSegueWithIdentifier:kPushLetterIdentifier sender:attachment];
        }
    }
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

*/

#pragma mark - Private methods

- (void)updateContentsFromServer
{
    [[SHCAPIManager sharedManager] updateDocumentsInFolderWithName:self.folderName folderUri:self.folderUri withSuccess:^{
        [self updateFetchedResultsController];
        [self programmaticallyEndRefresh];
    } failure:^(NSError *error) {

        [self programmaticallyEndRefresh];

        [UIAlertView showWithTitle:error.errorTitle
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[error.okButtonTitle]
                          tapBlock:error.tapBlock];
    }];
}

- (void)updateNavbar
{
    self.navigationItem.title = self.folderName;
}

@end
