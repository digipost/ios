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

#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
#import <UIAlertView+Blocks.h>
#import "SHCAttachmentsViewController.h"
#import "SHCAttachmentTableViewCell.h"
#import "POSAttachment.h"
#import "POSDocument.h"
#import "SHCAppDelegate.h"
#import "POSLetterViewController.h"
#import "UIViewController+ValidateOpening.h"
#import "POSAPIManager.h"
#import "NSError+ExtraInfo.h"
#import "UIView+AutoLayout.h"
#import "UILabel+Digipost.h"
#import "POSModelManager.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushAttachmentsIdentifier = @"PushAttachments";

// Google Analytics screen name
NSString *const kAttachmentsViewControllerScreenName = @"Attachments";

@interface SHCAttachmentsViewController ()

@end

@implementation SHCAttachmentsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:nil
                                                                         action:nil];
    
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self generateTableViewHeader];
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
    
    // Since this is a UITableViewController subclass, and we can't subclass the GAITrackedViewController,
    // we'll manually track and submit screen hits.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:kAttachmentsViewControllerScreenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    NSLog(@"%@",self.attachments);
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

- (void)reloadTableViewDataForDocument:(POSDocument*)document
{
    
    self.attachments = document.attachments;
    [self.tableView reloadData];
}

#pragma mark UI generation

- (void)generateTableViewHeader
{
    POSAttachment *firstAttachment = [self.attachments firstObject];
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
    [dateFormatter setDateFormat:NSLocalizedString(@"ATTACHMENTS_DATE_FORMAT", @"dd.MM.YYYY 'kl.' HH:mm")];
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
    POSAttachment *attachment = self.attachments[indexPath.row];
    NSLog(@"attachement uri %@ receipt uri: %@,attachment %@",attachment.uri,attachment.openingReceiptUri,attachment.subject);
    
    if (attachment.openingReceiptUri){
        [UIAlertView showWithTitle:NSLocalizedString(@"Avsender krever lesekvittering", @"Avsender krever lesekvittering")
                           message:NSLocalizedString(@"Hvis du åpner dette brevet", @"Hvis du åpner dette brevet")
                 cancelButtonTitle:NSLocalizedString(@"Avbryt", @"Avbryt")
                 otherButtonTitles:@[ NSLocalizedString(@"Åpne brevet og send kvittering", @"Åpne brevet og send kvittering") ]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              switch (buttonIndex) {
                                  case 0:
                                      break;
                                  case 1:
                                  {
                                      [self shouldValidateOpeningReceipt:attachment];
                                      break;
                                  }
                                  case 2:
                                      break;
                                  default:
                                      break;
                              }
                          }];
        return;
    }
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

- (void)shouldValidateOpeningReceipt:(POSAttachment*)attachment {
    {
        [[POSAPIManager sharedManager] validateOpeningReceipt:attachment success:^(NSDictionary *attachmentAttributes) {
            [self validateOpeningAttachment:attachment
                                    success:^{
                                        POSAttachment *refetchedAttachment = [POSAttachment updateExistingAttachmentWithUriFromDictionary:attachmentAttributes existingAttachment:attachment inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                                        [[POSModelManager sharedManager] logSavingManagedObjectContext];
                                        [self reloadTableViewDataForDocument:refetchedAttachment.document];
                                        
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
                                                              [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                                          }];
                                    }];
            
        } failure:^(NSError *error) {
            [UIAlertView showWithTitle:@"" message:@"" cancelButtonTitle:@"Ok" otherButtonTitles:@[] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }];
        
    }
}
@end
