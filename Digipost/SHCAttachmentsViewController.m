//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#import <UIAlertView_blocks/UIAlertView+Blocks.h>
#import "SHCAttachmentsViewController.h"
#import "SHCAttachmentTableViewCell.h"
#import "POSAttachment.h"
#import "POSDocument.h"
#import "SHCAppDelegate.h"
#import "POSLetterViewController.h"
#import "UIViewController+ValidateOpening.h"
#import "NSError+ExtraInfo.h"
#import "UIView+AutoLayout.h"
#import "UILabel+Digipost.h"
#import "POSModelManager.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushAttachmentsIdentifier = @"PushAttachments";

@interface SHCAttachmentsViewController ()

@property (nonatomic, strong) NSOrderedSet *attachments;

@end

@implementation SHCAttachmentsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self generateTableViewHeader];
    // select first row
    self.attachments = [self attachmentsForCurrentDocument];
    POSAttachment *attachment = self.attachments[0];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self validateOpeningAttachment:attachment
            success:^{
                                    ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = attachment;
            }
            failure:^(NSError *error) {
                                [UIAlertView showWithTitle:error.errorTitle
                                                   message:[error localizedDescription]
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@[error.okButtonTitle]
                                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  }];
            }];
    }
}

- (NSOrderedSet *)attachmentsForCurrentDocument
{
    POSDocument *currentDocument = [POSDocument existingDocumentWithUpdateUri:self.currentDocumentUpdateURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    return currentDocument.attachments;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:YES
                                       animated:NO];

    // Sometimes, the previously selected cell isn't properly deselected.
    // The line below makes sure all visible cells are deselected, plus it adds a
    // fancy fading effect when the user swipes back to this view controller
    NSIndexPath *indexPathForSelectedRow = [self.tableView indexPathForSelectedRow];
    if (indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:indexPathForSelectedRow
                                      animated:YES];
    }



    self.attachments = [self attachmentsForCurrentDocument];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.view.window.rootViewController;
        if ([splitViewController isKindOfClass:[UISplitViewController class]]) {
            UINavigationController *navigationController = (UINavigationController *)[splitViewController.viewControllers lastObject];
            if ([navigationController isKindOfClass:[UINavigationController class]]) {
                POSLetterViewController *letterViewController = (POSLetterViewController *)navigationController.topViewController;
                if ([letterViewController isKindOfClass:[POSLetterViewController class]]) {
                    [letterViewController updateLeftBarButtonItem:nil
                                                forViewController:self];
                }
            }
        }
    }

    [super viewWillDisappear:animated];
}

- (void)reloadTableViewDataForDocument:(POSDocument *)document
{
    self.attachments = document.attachments;
    [self.tableView reloadData];
}

#pragma mark UI generation

- (void)generateTableViewHeader
{
    POSAttachment *firstAttachment = [self.attachments firstObject];
    if (firstAttachment == nil) {
        firstAttachment = [self attachmentsForCurrentDocument].firstObject;
    }
    UIView *tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                        0.0,
                                                                        CGRectGetWidth(self.view.frame),
                                                                        75.0)];
    UILabel *headerFromLabel = [UILabel tableViewMediumHeaderLabel];
    [tableHeaderView addSubview:headerFromLabel];
    headerFromLabel.text = NSLocalizedString(@"GENERIC_FROM_LABEL", @"Fra");

    UILabel *headerDateTitleLabel = [UILabel tableViewMediumHeaderLabel];
    headerDateTitleLabel.text = NSLocalizedString(@"GENERIC_DATE_LABEL", @"Dato");
    [tableHeaderView addSubview:headerDateTitleLabel];

    UILabel *headerFromTextLabel = [UILabel tableViewRegularHeaderLabel];
    headerFromTextLabel.text = firstAttachment.document.creatorName;
    [tableHeaderView addSubview:headerFromTextLabel];

    UILabel *headerDateTextLabel = [UILabel tableViewRegularHeaderLabel];
    // Dateformatter for format: 2013-02-15 09:49
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:NSLocalizedString(@"ATTACHMENTS_DATE_FORMAT", @"dd.MMM.YYYY 'kl.' HH:mm")];
    headerDateTextLabel.text = [dateFormatter stringFromDate:firstAttachment.document.createdAt];
    [tableHeaderView addSubview:headerDateTextLabel];

    [headerFromLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerDateTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerDateTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerFromTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [tableHeaderView addOriginConstraintForOrigin:CGPointMake(15, 10)
                                    containedView:headerFromLabel];
    [headerFromLabel addSizeConstraint:CGSizeMake(60, 30)];

    [tableHeaderView addOriginConstraintForOrigin:CGPointMake(15, 35)
                                    containedView:headerDateTitleLabel];
    [headerDateTitleLabel addSizeConstraint:CGSizeMake(60, 30)];

    [tableHeaderView addOriginConstraintForOrigin:CGPointMake(80, 10)
                                    containedView:headerFromTextLabel];
    [headerFromTextLabel addSizeConstraint:CGSizeMake(210, 30)];

    [tableHeaderView addOriginConstraintForOrigin:CGPointMake(80, 35)
                                    containedView:headerDateTextLabel];
    [headerDateTextLabel addSizeConstraint:CGSizeMake(210, 30)];

    [self.tableView setTableHeaderView:tableHeaderView];
    // This line makes the tableview hide its separator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushLetterIdentifier]) {
        POSAttachment *attachment = (POSAttachment *)sender;

        POSLetterViewController *letterViewController = (POSLetterViewController *)segue.destinationViewController;
        letterViewController.documentsViewController = self.documentsViewController;
        letterViewController.attachment = attachment;
        letterViewController.indexOfAttachment = self.tableView.indexPathForSelectedRow.row;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attachments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POSAttachment *attachment = self.attachments[indexPath.row];

    SHCAttachmentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kAttachmentTableViewCellIdentifier
                                                                            forIndexPath:indexPath];

    cell.subjectLabel.text = attachment.subject;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.attachments = [self attachmentsForCurrentDocument];
    POSAttachment *attachment = self.attachments[indexPath.row];

    [self validateOpeningAttachment:attachment
        success:^{
                                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                    ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = attachment;
                                } else {
                                    [self performSegueWithIdentifier:kPushLetterIdentifier sender:attachment];
                                }
        }
        failure:^(NSError *error) {
                                [UIAlertView showWithTitle:error.errorTitle
                                                   message:[error localizedDescription]
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@[error.okButtonTitle]
                                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                      [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                                  }];
        }];
}

- (void)shouldValidateOpeningReceipt:(POSAttachment *)attachment
{
    {
        //        [[POSAPIManager sharedManager] validateOpeningReceipt:attachment success:^(NSDictionary *attachmentAttributes) {
        //            [self validateOpeningAttachment:attachment
        //                                    success:^{
        //                                        POSAttachment *refetchedAttachment = [POSAttachment updateExistingAttachmentWithUriFromDictionary:attachmentAttributes existingAttachment:attachment inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        //                                        [[POSModelManager sharedManager] logSavingManagedObjectContext];
        //                                        [self reloadTableViewDataForDocument:refetchedAttachment.document];
        //
        //                                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //                                            ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = attachment;
        //                                        } else {
        //                                            [self performSegueWithIdentifier:kPushLetterIdentifier sender:attachment];
        //                                        }
        //                                    }
        //                                    failure:^(NSError *error) {
        //                                        [UIAlertView showWithTitle:error.errorTitle
        //                                                           message:[error localizedDescription]
        //                                                 cancelButtonTitle:nil
        //                                                 otherButtonTitles:@[error.okButtonTitle]
        //                                                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //                                                              [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        //                                                          }];
        //                                    }];
        //
        //        } failure:^(NSError *error) {
        //            [UIAlertView showWithTitle:@"" message:@"" cancelButtonTitle:@"Ok" otherButtonTitles:@[] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //
        //            }];
        //        }];
    }
}
@end
