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
#import "POSFoldersViewController.h"
#import "POSNewFolderViewController.h"
#import "NSPredicate+CommonPredicates.h"
#import <UIAlertView+Blocks.h>
#import "POSAPIManager.h"
#import "POSModelManager.h"
#import "POSFolderTableViewCell.h"
#import "POSDocument+Methods.h"
#import "UILabel+Digipost.h"
#import "POSFolder.h"
#import "POSMailbox+Methods.h"
#import "POSMailbox.h"
#import "POSOAuthManager.h"
#import "SHCLoginViewController.h"
#import "POSDocumentsViewController.h"
#import "POSRootResource.h"
#import "UIColor+Convenience.h"
#import "NSError+ExtraInfo.h"
#import "POSReceiptFoldersTableViewController.h"
#import "POSLetterViewController.h"
#import <UIActionSheet+Blocks.h>
#import "SHCAppDelegate.h"
#import "UIViewController+BackButton.h"
#import "POSAccountViewController.h"
#import "Digipost-Swift.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kFoldersViewControllerIdentifier = @"FoldersViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushFoldersIdentifier = @"PushFolders";
NSString *const kUploadFileSegueIdentifier = @"uploadFileSegue";

// Google Analytics screen name
NSString *const kFoldersViewControllerScreenName = @"Folders";

NSString *const kGoToInboxFolderAtStartupSegue = @"goToInboxFolderAtStartupSegue";

NSString *const kEditFolderSegue = @"newFolderSegue";

@interface POSFoldersViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSMutableArray *folders;
@property (nonatomic) BOOL shouldShowAddNewFolderCell;
@property (strong, nonatomic) POSFolder *inboxFolder;
@property (strong, nonatomic) UploadImageController *uploadImageController;

@end

@implementation POSFoldersViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.shouldShowAddNewFolderCell = YES;
    [self.tableView setAllowsSelectionDuringEditing:YES];
    self.baseEntity = [[POSModelManager sharedManager] folderEntity];

    [self pos_setDefaultBackButton];
    self.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(index))
                                                            ascending:YES
                                                             selector:@selector(compare:)] ];
    POSMailbox *currentMailbox = nil;
    if (self.selectedMailBoxDigipostAdress == nil) {
        currentMailbox = [POSMailbox mailboxInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        self.selectedMailBoxDigipostAdress = currentMailbox.digipostAddress;
        NSAssert(self.selectedMailBoxDigipostAdress != nil, @"No mailbox stored");
    } else {
        currentMailbox = [POSMailbox existingMailboxWithDigipostAddress:self.selectedMailBoxDigipostAdress
                                                 inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
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

    UINavigationItem *navItem = self.navigationController.navigationBar.items[0];

    if ([navItem.title isEqualToString:@""] == NO) {
        if (currentMailbox == nil) {
            currentMailbox = [POSMailbox mailboxInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        }
        navItem.title = currentMailbox.name;
        if (navItem.leftBarButtonItem == nil) {
            UIImage *image = [UIImage imageNamed:@"back"];
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:image
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(popViewController)];
            backButton.title = @" ";
            backButton.accessibilityLabel = NSLocalizedString(@"Accessability backbutton title", @"name of back button");
            backButton.accessibilityHint = NSLocalizedString(@"Accessability backbutton title", @"name of back button");
            [backButton setImageInsets:UIEdgeInsetsMake(3, -8, 0, 0)];
            [navItem setLeftBarButtonItem:backButton];
        }
        [navItem setRightBarButtonItem:self.editButtonItem];
    }
    if (navItem.rightBarButtonItem == nil) {
        navItem.rightBarButtonItem = self.editButtonItem;
    }
}

- (void)popViewController
{
    NSAssert(self.navigationController != nil, @"no nav controller");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.selectedMailBoxDigipostAdress) {
        POSMailbox *currentMailbox = [POSMailbox existingMailboxWithDigipostAddress:self.selectedMailBoxDigipostAdress
                                                             inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        UINavigationItem *navItem = self.navigationController.navigationBar.items[0];
        navItem.title = currentMailbox.name;
        self.navigationItem.title = currentMailbox.name;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateContentsFromServerUserInitiatedRequest:@NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[POSAPIManager sharedManager] cancelUpdatingRootResource];

    [self programmaticallyEndRefresh];

    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushDocumentsIdentifier]) {
        POSFolder *folder = (POSFolder *)sender;
        POSDocumentsViewController *documentsViewController = (POSDocumentsViewController *)segue.destinationViewController;
        documentsViewController.folderName = folder.name;
        documentsViewController.folderDisplayName = folder.displayName;
        documentsViewController.folderUri = folder.uri;
        documentsViewController.selectedFolder = folder;
        documentsViewController.mailboxDigipostAddress = self.selectedMailBoxDigipostAdress;
    } else if ([segue.identifier isEqualToString:kPushReceiptsIdentifier]) {
        POSReceiptFoldersTableViewController *receiptsViewController = (POSReceiptFoldersTableViewController *)segue.destinationViewController;
        receiptsViewController.mailboxDigipostAddress = self.inboxFolder.mailbox.digipostAddress;
        receiptsViewController.receiptsUri = self.inboxFolder.mailbox.receiptsUri;
    } else if ([segue.identifier isEqualToString:kGoToInboxFolderAtStartupSegue]) {
        POSDocumentsViewController *documentsViewController = (POSDocumentsViewController *)segue.destinationViewController;
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
    NSUInteger numberOfSections = 0;

    if (self.inboxFolder) {
        numberOfSections++;
    }

    if ([self.folders count] > 0) {
        numberOfSections++;
    }

    if (self.editing && [self.folders count] == 0) {
        numberOfSections++;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.inboxFolder) {
        if (__IS_BETA__ == 1) {
            return 4;
        }
        return 3; // Inbox, Receipts and upload
    } else {
        if (self.isEditing && self.shouldShowAddNewFolderCell) {
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

    POSFolderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFolderTableViewCellIdentifier
                                                                   forIndexPath:indexPath];
    if (indexPath.section == 0 && self.inboxFolder) {
        switch (indexPath.row) {
            case 0: {
                folderName = [self.inboxFolder displayName];
                iconImage = [UIImage imageNamed:@"list-icon-inbox"];
                unreadCounterHidden = NO;
            } break;
            case 1: {
                folderName = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_RECEIPTS_TITLE", @"Receipts");
                iconImage = [UIImage imageNamed:@"list-icon-receipt"];
            } break;
            case 2: {
                folderName = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_UPLOAD_TITLE", @"Upload");
                iconImage = [UIImage imageNamed:@"Upload"];
            } break;
            case 3: {
                folderName = NSLocalizedString(@"folder view controller beta title", @"tells user that they can send feedback with this button");
                iconImage = [UIImage imageNamed:@"Feedback"];
            } break;

            default:
                break;
        }
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
        NSInteger unread = [POSDocument numberOfUnreadDocumentsForMailboxFolder:self.inboxFolder inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        cell.unreadCounterLabel.text = [NSString stringWithFormat:@"%li", (long)unread];
    }

    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing
             animated:animated];

    if (editing) {
        self.shouldShowAddNewFolderCell = YES;
        if ([self.folders count] == 0) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:[self.folders count]
                                                                         inSection:1] ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if (animated) {
        if ([self.folders count] == 0) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:[self.folders count]
                                                                         inSection:1] ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
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
            if (indexPath.row >= [self.folders count]) {
                return NO;
            }
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.shouldShowAddNewFolderCell = NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row
                                  inSection:sourceIndexPath.section];
    } else if (proposedDestinationIndexPath.row == [self.folders count]) {
        return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row - 1
                                  inSection:sourceIndexPath.section];
    }

    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *newSorting = [self.folders mutableCopy];
    POSFolder *firstFolder = self.folders[sourceIndexPath.row];
    BOOL movingUpwards = NO;
    if (sourceIndexPath.row > destinationIndexPath.row) {
        movingUpwards = YES;
    }

    [self.folders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        POSFolder *folder = (id)obj;
        if (idx == destinationIndexPath.row){
            [newSorting setObject:firstFolder atIndexedSubscript:idx];
            firstFolder.index = @( idx );
        } else if (idx == sourceIndexPath.row){
            if (movingUpwards){
                POSFolder *objatBeforeindex = (id)[self.folders objectAtIndex:idx - 1];
                [newSorting setObject: objatBeforeindex  atIndexedSubscript:idx];
                objatBeforeindex.index = @( idx );
            }else {
                POSFolder *objNextIndex = (id) [self.folders objectAtIndex:idx  + 1];
                [newSorting setObject: objNextIndex  atIndexedSubscript:idx];
                objNextIndex.index = @( idx );
            }
        } else if(idx >= destinationIndexPath.row && (idx <= sourceIndexPath.row) && movingUpwards) {
            POSFolder *objatBeforeindex = (id)[self.folders objectAtIndex:idx - 1];
            [newSorting setObject: objatBeforeindex  atIndexedSubscript:idx];
            objatBeforeindex.index = @( idx );
        } else if (idx <= destinationIndexPath.row && (idx >= sourceIndexPath.row) && !movingUpwards) {
            POSFolder *objNextIndex = (id) [self.folders objectAtIndex:idx + 1];
            [newSorting setObject: objNextIndex  atIndexedSubscript:idx];
            objNextIndex.index = @( idx );
        } else {
            [newSorting setObject:obj atIndexedSubscript:idx];
            folder.index = @( idx );
        }
    }];

    self.folders = newSorting;
    POSMailbox *mailbox = [POSMailbox existingMailboxWithDigipostAddress:self.selectedMailBoxDigipostAdress
                                                  inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];

    [[POSAPIManager sharedManager] moveFolder:newSorting
        mailbox:mailbox
        success:^{
                                          NSError *error;
                                          [[POSModelManager sharedManager].managedObjectContext save:&error];
                                          if (error){
                                              [[POSModelManager sharedManager] logSavingManagedObjectContextWithError:error];
                                          }
        }
        failure:^(NSError *error){}];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            if (indexPath.row >= [self.folders count]) {
                return NO;
            }
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
        if (self.folders.count == 1) {
            NSIndexSet *indexset = [[NSIndexSet alloc] initWithIndex:1];
            [self.tableView reloadSections:indexset withRowAnimation:UITableViewRowAnimationNone];
        }
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

    if (self.tableView.isEditing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat labelHeight = 21.0;
    CGFloat labelOriginX = 15.0;
    CGFloat headerHeight = [self tableView:tableView
                  heightForHeaderInSection:section];

    UILabel *headerLabel = [UILabel folderSectionHeaderTitleLabelWithFrame:CGRectMake(labelOriginX,
                                                                                      headerHeight - labelHeight - 4,
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFolderViewControllerNavigatedInList" object:nil];
    }

    if (self.isEditing == NO) {
        if (indexPath.section == 0 && self.inboxFolder) {
            switch (indexPath.row) {
                case 0: {
                    [self performSegueWithIdentifier:kPushDocumentsIdentifier
                                              sender:self.inboxFolder];
                    break;
                }
                case 1: {
                    [self performSegueWithIdentifier:kPushReceiptsIdentifier
                                              sender:nil];
                    break;
                }
                case 2: {
                    [self performSegueWithIdentifier:@"uploadMenuSegue" sender:self];

                    break;
                } break;
                case 3: {
                    NSURL *url = [[NSURL alloc] initWithString:@"http://labs.digipost.no"];
                    [[UIApplication sharedApplication] openURL:url];
                }
                default:
                    break;
            }
        } else {
            [self performSegueWithIdentifier:kPushDocumentsIdentifier
                                      sender:self.folders[indexPath.row]];
        }
    } else {
        if (indexPath.section != 0) {
            [self performSegueWithIdentifier:kEditFolderSegue
                                      sender:self];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.isEditing) {
        if (indexPath.section == 0) {
            return nil;
        }
    }
    return indexPath;
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
    if ([POSAPIManager sharedManager].isUpdatingRootResource) {
        return;
    }
    [[POSAPIManager sharedManager] updateRootResourceWithSuccess:^{
        self.rootResource = nil; // To force a refetch of this property
        [self updateFetchedResultsController];
        [self programmaticallyEndRefresh];
        [self updateNavbar];
    } failure:^(NSError *error) {
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
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
}

- (void)deleteFolder:(POSFolder *)folder atIndexPath:(NSIndexPath *)indexPath
{
    [[POSAPIManager sharedManager] delteFolder:folder
        success:^{
            [self updateContentsFromServerUserInitiatedRequest:@NO];
        }
        failure:^(NSError *error) {
                                           [UIAlertView showWithTitle:NSLocalizedString(@"Not empty folder alert title", @"Title of alert informing user that folder is not empty") message:NSLocalizedString(@"Not empty folder alert descrption ", @"Description of user telling folder is not empty") cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               
                                           }];
        }];
}

- (void)uploadProgressDidStart:(NSNotification *)notification
{
}
- (IBAction)unwindToFoldersViewController:(UIStoryboardSegue *)unwindSegue
{
}
@end
