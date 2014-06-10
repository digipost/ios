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

#import "POSFolder+Methods.h"
#import <UIAlertView+Blocks.h>
#import "POSFolderIcon.h"
#import <AFNetworking/AFURLConnectionOperation.h>
#import "SHCFoldersViewController.h"
#import "POSNewFolderViewController.h"
#import "NSPredicate+CommonPredicates.h"
#import <UIAlertView+Blocks.h>
#import "SHCAPIManager.h"
#import "POSModelManager.h"
#import "SHCFolderTableViewCell.h"
#import "UILabel+Digipost.h"
#import "POSFolder.h"
#import "POSMailbox+Methods.h"
#import "POSMailbox.h"
#import "SHCOAuthManager.h"
#import "SHCLoginViewController.h"
#import "SHCDocumentsViewController.h"
#import "POSRootResource.h"
#import "UIColor+Convenience.h"
#import "NSError+ExtraInfo.h"
#import "SHCReceiptFoldersTableViewController.h"
#import "SHCLetterViewController.h"
#import "SHCAppDelegate.h"
#import "POSAccountViewController.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kFoldersViewControllerIdentifier = @"FoldersViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushFoldersIdentifier = @"PushFolders";

// Google Analytics screen name
NSString *const kFoldersViewControllerScreenName = @"Folders";

NSString *const kGoToInboxFolderAtStartupSegue = @"goToInboxFolderAtStartupSegue";

NSString *const kEditFolderSegue = @"newFolderSegue";

@interface SHCFoldersViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSMutableArray *folders;
@property (strong, nonatomic) POSFolder *inboxFolder;

@end

@implementation SHCFoldersViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [self.tableView setAllowsSelectionDuringEditing:YES];
    self.baseEntity = [[POSModelManager sharedManager] folderEntity];
    self.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(name))
                                                            ascending:NO
                                                             selector:@selector(compare:)] ];

    if (self.selectedMailBoxDigipostAdress == nil) {
        POSMailbox *mailbox = [POSMailbox mailboxInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        self.selectedMailBoxDigipostAdress = mailbox.digipostAddress;
        NSAssert(self.selectedMailBoxDigipostAdress != nil, @"No mailbox stored");
    }

    self.predicate = [NSPredicate predicateWithFoldersInMailbox:self.selectedMailBoxDigipostAdress];
    self.screenName = kFoldersViewControllerScreenName;
    self.folders = [NSMutableArray array];
    [super viewDidLoad];

    [self.navigationItem setRightBarButtonItem:self.editButtonItem];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadProgressDidStart:)
                                                 name:kAPIManagerUploadProgressStartedNotificationName
                                               object:nil];

    if ([self.navigationController.viewControllers[1] isMemberOfClass:[POSAccountViewController class]] == NO) {
        POSAccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:kAccountViewControllerIdentifier];
        NSMutableArray *newViewControllerArray = [NSMutableArray array];
        NSInteger index = 0;
        // add account vc as second view controller in navigation controller
        for (UIViewController *viewController in self.navigationController.viewControllers) {
            [newViewControllerArray addObject:viewController];
            if (index == 0) {
                [newViewControllerArray addObject:accountViewController];
            }
            index++;
        }
        [self.navigationController setViewControllers:newViewControllerArray
                                             animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateContentsFromServerUserInitiatedRequest:@NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SHCAPIManager sharedManager] cancelUpdatingRootResource];

    [self programmaticallyEndRefresh];

    [super viewWillDisappear:animated];
    [self setEditing:NO
            animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushDocumentsIdentifier]) {
        POSFolder *folder = (POSFolder *)sender;
        SHCDocumentsViewController *documentsViewController = (SHCDocumentsViewController *)segue.destinationViewController;
        documentsViewController.folderName = folder.name;
        documentsViewController.folderDisplayName = folder.displayName;
        documentsViewController.folderUri = folder.uri;
        documentsViewController.selectedFolder = folder;
        documentsViewController.mailboxDigipostAddress = self.selectedMailBoxDigipostAdress;
    } else if ([segue.identifier isEqualToString:kPushReceiptsIdentifier]) {
        SHCReceiptFoldersTableViewController *receiptsViewController = (SHCReceiptFoldersTableViewController *)segue.destinationViewController;
        receiptsViewController.mailboxDigipostAddress = self.inboxFolder.mailbox.digipostAddress;
        receiptsViewController.receiptsUri = self.inboxFolder.mailbox.receiptsUri;
    } else if ([segue.identifier isEqualToString:kGoToInboxFolderAtStartupSegue]) {
        SHCDocumentsViewController *documentsViewController = (SHCDocumentsViewController *)segue.destinationViewController;
        documentsViewController.folderName = kFolderInboxName;
    } else if ([segue.identifier isEqualToString:kEditFolderSegue]) {
        POSNewFolderViewController *newFolderVC = (POSNewFolderViewController *)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        newFolderVC.selectedFolder = nil;
        newFolderVC.mailbox = self.inboxFolder.mailbox;
        if ([self.folders count] > selectedIndexPath.row) {
            if (selectedIndexPath != nil) {
                newFolderVC.selectedFolder = self.folders[selectedIndexPath.row];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger numberOfSections = 1; // We always want the Settings section

    if (self.inboxFolder) {
        numberOfSections++;
    }
    if ([self.folders count] > 0) {
        numberOfSections++;
    }

    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.inboxFolder) {
        return 2; // Inbox and Receipts
    } else if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return 1; // Only Sign Out for now
    } else {
        if (self.isEditing) {
            // add new cell-cell is added
            return [self.folders count] + 1;
        } else {
            return [self.folders count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *folderName;
    UIImage *iconImage;
    BOOL arrowHidden = NO;
    BOOL unreadCounterHidden = YES;

    SHCFolderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFolderTableViewCellIdentifier
                                                                   forIndexPath:indexPath];
    if (indexPath.section == 0 && self.inboxFolder) {
        if (indexPath.row == 0) {
            folderName = [self.inboxFolder displayName];
            iconImage = [UIImage imageNamed:@"list-icon-inbox"];
            unreadCounterHidden = NO;
        } else {
            folderName = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_RECEIPTS_TITLE", @"Receipts");
            iconImage = [UIImage imageNamed:@"list-icon-receipt"];
        }
    } else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {
        folderName = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", @"Sign Out");
        iconImage = [UIImage imageNamed:@"list-icon-logout"];
        arrowHidden = YES;
    } else {
        if (indexPath.row >= [self.folders count]) {
            folderName = NSLocalizedString(@"FOLDER_VIEW_ADD_NEW_FOLDER_TEXT", @"Legg til mappe");
        } else {
            folderName = [self.folders[indexPath.row] displayName];
            POSFolder *folder = self.folders[indexPath.row];
            POSFolderIcon *folderIcon = [POSFolderIcon folderIconWithName:folder.iconName];
            iconImage = folderIcon.smallImage;
        }
    }

    cell.backgroundColor = [UIColor colorWithRed:64.0 / 255.0
                                           green:66.0 / 255.0
                                            blue:69.0 / 255.0
                                           alpha:1.0];
    cell.folderNameLabel.text = folderName;
    cell.iconImageView.image = iconImage;
    cell.arrowImageView.hidden = arrowHidden;
    cell.unreadCounterImageView.hidden = unreadCounterHidden;
    cell.unreadCounterLabel.hidden = unreadCounterHidden;

    if (!unreadCounterHidden) {
        POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        cell.unreadCounterLabel.text = [NSString stringWithFormat:@"%@", rootResource.unreadItemsInInbox];
    }

    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing
             animated:animated];

    NSInteger numberOfRowsShowing = [self.tableView numberOfRowsInSection:1];
    if (editing) {
        [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:[self.folders count]
                                                                     inSection:1] ]
                              withRowAnimation:UITableViewRowAnimationAutomatic];

    } else if (animated) {
        //        if ([self.folders count] > numberOfRowsShowing) {
        [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:[self.folders count]
                                                                     inSection:1] ]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        //        }
    } else {
    }
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height;
    if (section == 0 && self.inboxFolder) {
        height = 0.0;
    } else {
        height = self.tableView.sectionHeaderHeight;
    }

    return height;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            //            if (indexPath.row >= [self.folders count]) {
            //                return NO;
            //            }
            return YES;
            break;
        default:
            break;
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            //            if (indexPath.row >= [self.folders count]) {
            //                return NO;
            //            }
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        POSFolder *folder = [self.folders objectAtIndex:indexPath.row];
        [self deleteFolder:folder
               atIndexPath:indexPath];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self performSegueWithIdentifier:@"newFolderSegue"
                                  sender:self];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.folders count]) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat labelHeight = 21.0;
    CGFloat labelOriginX = 15.0;
    CGFloat headerHeight = [self tableView:tableView
                  heightForHeaderInSection:section];

    UILabel *headerLabel = [UILabel folderSectionHeaderTitleLabelWithFrame:CGRectMake(labelOriginX,
                                                                                      headerHeight - labelHeight,
                                                                                      CGRectGetWidth(tableView.frame) - labelOriginX,
                                                                                      labelHeight)];

    NSString *title;
    if (section == 0 && self.inboxFolder) {
        title = nil;
    } else if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        title = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_SETTINGS_SECTION_HEADER_TITLE", @"SETTINGS");
    } else {
        title = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_FOLDERS_SECTION_HEADER_TITLE", @"FOLDERS");
    }

    headerLabel.text = title;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                            0.0,
                                                            CGRectGetWidth(tableView.frame),
                                                            headerHeight)];
    [view addSubview:headerLabel];
    [view setBackgroundColor:[UIColor pos_colorWithR:64
                                                   G:66
                                                   B:69]];

    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing == NO) {
        if (indexPath.section == 0 && self.inboxFolder) {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:kPushDocumentsIdentifier
                                          sender:self.inboxFolder];
            } else {
                [self performSegueWithIdentifier:kPushReceiptsIdentifier
                                          sender:nil];
            }
        } else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {
        } else {
            [self performSegueWithIdentifier:kPushDocumentsIdentifier
                                      sender:self.folders[indexPath.row]];
        }
    } else {
        [self performSegueWithIdentifier:kEditFolderSegue
                                  sender:self];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self updateFolders];
}

#pragma mark - Public methods

- (void)updateFolders
{
    [self.folders removeAllObjects];

    for (NSInteger section = 0; section < [self.fetchedResultsController.sections count]; section++) {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
        for (NSInteger row = 0; row < sectionInfo.numberOfObjects; row++) {
            POSFolder *folder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row
                                                                                                    inSection:section]];
            if ([[folder.name lowercaseString] isEqualToString:[kFolderInboxName lowercaseString]]) {
                self.inboxFolder = folder;
            } else {
                [self.folders addObject:folder];
            }
        }
    }
}

#pragma mark - Private methods

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *)userDidInititateRequest
{
    if ([SHCAPIManager sharedManager].isUpdatingRootResource) {
        return;
    }

    [[SHCAPIManager sharedManager] updateRootResourceWithSuccess:^{
        self.rootResource = nil; // To force a refetch of this property
        [self updateFetchedResultsController];
        [self programmaticallyEndRefresh];
        [self updateNavbar];
    } failure:^(NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                // We were unauthorized, due to the session being invalid.
                // Let's retry in the next run loop
                [self performSelector:@selector(updateContentsFromServerUserInitiatedRequest:) withObject:userDidInititateRequest afterDelay:0.0];

                return;
            }
        }

        [self programmaticallyEndRefresh];
        if ([userDidInititateRequest boolValue]) {
            [UIAlertView showWithTitle:error.errorTitle
                               message:[error localizedDescription]
                     cancelButtonTitle:nil
                     otherButtonTitles:@[error.okButtonTitle]
                              tapBlock:error.tapBlock];
        }
    }];
}

- (void)updateNavbar
{
    [super updateNavbar];

    [self.navigationItem setTitle:@""];
    //    [self.navigationItem setHidesBackButton:YES];

    self.navigationItem.title = self.selectedMailBoxDigipostAdress ?: @"";
}

- (void)deleteFolder:(POSFolder *)folder atIndexPath:(NSIndexPath *)indexPath
{
    [[SHCAPIManager sharedManager] delteFolder:folder
        success:^{
            [self updateContentsFromServerUserInitiatedRequest:@NO];
        }
        failure:^(NSError *error) {
            [UIAlertView showWithTitle:NSLocalizedString(@"Feil", @"Feil") message:NSLocalizedString(@"Noe feil skjedde. Sikker på at mappa er tom? ", @"Noe feil skjedde. Sikker på at mappa er tom? ") cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }];
}

- (void)uploadProgressDidStart:(NSNotification *)notification
{
    UIViewController *topViewController = [self.navigationController topViewController];
    SHCDocumentsViewController *archiveViewController = (SHCDocumentsViewController *)topViewController;

    if (!([topViewController isKindOfClass:[SHCDocumentsViewController class]] && [archiveViewController.folderName isEqualToString:kFolderArchiveName])) {

        [self.navigationController popToViewController:self.navigationController.viewControllers[1]
                                              animated:NO];
        // @TODO  enure you got the correct VC !!!!!!!!
        for (POSFolder *folder in self.folders) {
            if ([[folder.name lowercaseString] isEqualToString:[kFolderArchiveName lowercaseString]]) {
                [self performSegueWithIdentifier:kPushDocumentsIdentifier
                                          sender:folder];
            }
        }
    }
}

@end
