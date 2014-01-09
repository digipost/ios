//
//  SHCDocumentsViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIAlertView+Blocks.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import <TTTTimeIntervalFormatter.h>
#import "SHCDocumentsViewController.h"
#import "SHCModelManager.h"
#import "SHCDocument.h"
#import "SHCDocumentTableViewCell.h"
#import "SHCAttachment.h"
#import "SHCAPIManager.h"
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

@property (strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *weekdayDateFormatter;

@end

@implementation SHCDocumentsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"dd.MM.yy";

    self.weekdayDateFormatter = [[NSDateFormatter alloc] init];
    self.weekdayDateFormatter.dateFormat = @"EEEE";

    self.baseEntity = [[SHCModelManager sharedManager] documentEntity];
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(createdAt))
                                                           ascending:NO
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

    SHCDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDocumentTableViewCellIdentifier forIndexPath:indexPath];

    SHCAttachment *attachment = [document mainDocumentAttachment];

    cell.senderLabel.text = attachment.document.creatorName;
    cell.dateLabel.text = [self stringForDocumentDate:attachment.document.createdAt];
    cell.subjectLabel.text = attachment.subject;

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

        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsIn400Range:response]) {
                // We were unauthorized, due to the session being invalid.
                // Let's retry in the next run loop
                double delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self updateContentsFromServer];
                });
                return;
            }
        }

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

- (NSString *)stringForDocumentDate:(NSDate *)date
{
    NSDate *nowDate = [NSDate date];

    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:nowDate options:0];

    if (dateComponents.day > 6) {
        return [self.dateFormatter stringFromDate:date];
    } else if (dateComponents.day > 1) {
        return [self.weekdayDateFormatter stringFromDate:date];
    } else if (dateComponents.day == 1) {
        return NSLocalizedString(@"GENERIC_YESTERDAY_TITLE", @"Yesterday");
    } else {
        return [self.timeIntervalFormatter stringForTimeIntervalFromDate:nowDate toDate:date];
    }
}

@end
