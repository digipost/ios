//
//  SHCFoldersViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import "SHCFoldersViewController.h"
#import "SHCAPIManager.h"
#import "SHCModelManager.h"
#import "SHCFolderTableViewCell.h"
#import "SHCFolder.h"
#import "SHCMailbox.h"
#import "SHCOAuthManager.h"
#import "SHCLoginViewController.h"
#import "SHCDocumentsViewController.h"
#import "SHCRootResource.h"
#import "NSError+ExtraInfo.h"
#import "SHCReceiptsViewController.h"
#import "SHCLetterViewController.h"
#import "SHCAppDelegate.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kFoldersViewControllerIdentifier = @"FoldersViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushFoldersIdentifier = @"PushFolders";

// Google Analytics screen name
NSString *const kFoldersViewControllerScreenName = @"Folders";

NSString *const kGoToInboxFolderAtStartupSegue = @"goToInboxFolderAtStartupSegue";


@interface SHCFoldersViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSMutableArray *folders;
@property (strong, nonatomic) SHCFolder *inboxFolder;

@end

@implementation SHCFoldersViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.baseEntity = [[SHCModelManager sharedManager] folderEntity];
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(name))
                                                           ascending:NO
                                                            selector:@selector(compare:)]];

    self.predicate = [NSPredicate predicateWithFormat:@"%K == YES", [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(mailbox)), NSStringFromSelector(@selector(owner))]];

    self.screenName = kFoldersViewControllerScreenName;

    self.folders = [NSMutableArray array];

    [super viewDidLoad];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressDidStart:) name:kAPIManagerUploadProgressStartedNotificationName object:nil];
    UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setLeftBarButtonItem:emptyBarButtonItem];
    [self.navigationItem setHidesBackButton:YES];
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushDocumentsIdentifier]) {
        SHCFolder *folder = (SHCFolder *)sender;
        SHCDocumentsViewController *documentsViewController = (SHCDocumentsViewController *)segue.destinationViewController;
        documentsViewController.folderName = folder.name;
        documentsViewController.folderDisplayName = folder.displayName;
        documentsViewController.folderUri = folder.uri;
    } else if ([segue.identifier isEqualToString:kPushReceiptsIdentifier]) {
        SHCReceiptsViewController *receiptsViewController = (SHCReceiptsViewController *)segue.destinationViewController;
        receiptsViewController.mailboxDigipostAddress = self.inboxFolder.mailbox.digipostAddress;
        receiptsViewController.receiptsUri = self.inboxFolder.mailbox.receiptsUri;
    } else if ( [segue.identifier isEqualToString:kGoToInboxFolderAtStartupSegue]){
        SHCDocumentsViewController *documentsViewController = (SHCDocumentsViewController *)segue.destinationViewController;
        documentsViewController.folderName = kFolderInboxName;
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
        return [self.folders count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *folderName;
    UIImage *iconImage;
    BOOL arrowHidden = NO;
    BOOL unreadCounterHidden = YES;

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
        folderName = [self.folders[indexPath.row] displayName];
        iconImage = [UIImage imageNamed:@"list-icon-folder"];
    }

    SHCFolderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFolderTableViewCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:66.0/255.0 blue:69.0/255.0 alpha:1.0];
    cell.folderNameLabel.text = folderName;
    cell.iconImageView.image = iconImage;
    cell.arrowImageView.hidden = arrowHidden;
    cell.unreadCounterImageView.hidden = unreadCounterHidden;
    cell.unreadCounterLabel.hidden = unreadCounterHidden;

    if (!unreadCounterHidden) {
        SHCRootResource *rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
        cell.unreadCounterLabel.text = [NSString stringWithFormat:@"%@", rootResource.unreadItemsInInbox ];
    }

    return cell;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat labelHeight = 21.0;
    CGFloat labelOriginX = 15.0;
    CGFloat headerHeight = [self tableView:tableView heightForHeaderInSection:section];

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelOriginX,
                                                                     headerHeight - labelHeight,
                                                                     CGRectGetWidth(tableView.frame) - labelOriginX,
                                                                     labelHeight)];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    headerLabel.textColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];

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

    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.inboxFolder) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:kPushDocumentsIdentifier sender:self.inboxFolder];
        } else {
            [self performSegueWithIdentifier:kPushReceiptsIdentifier sender:nil];
        }
    } else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {

        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];

        [UIActionSheet showFromRect:[tableView convertRect:rect toView:self.view]
                             inView:self.view
                           animated:YES
                          withTitle:NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", @"You you sure you want to sign out?")
                  cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
             destructiveButtonTitle:NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", @"Sign out")
                  otherButtonTitles:nil
                           tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                               if (buttonIndex == 0) {
                                   SHCAppDelegate *appDelegate = (id) [UIApplication sharedApplication].delegate;
                                   SHCLetterViewController *letterViewConctroller = (id)appDelegate.letterViewController;
                                   letterViewConctroller.attachment = nil;
                                   letterViewConctroller.receipt = nil;
                                   [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewControllerNotificationName object:nil];

                                   [[SHCAPIManager sharedManager] logoutWithSuccess:^{

                                       [[SHCOAuthManager sharedManager] removeAllTokens];
                                       [[SHCModelManager sharedManager] deleteAllObjects];

                                   } failure:^(NSError *error) {

                                       [[SHCOAuthManager sharedManager] removeAllTokens];
                                       [[SHCModelManager sharedManager] deleteAllObjects];

                                       [UIAlertView showWithTitle:error.errorTitle
                                                          message:[error localizedDescription]
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@[error.okButtonTitle]
                                                         tapBlock:error.tapBlock];
                                   }];
                               }

                               [tableView deselectRowAtIndexPath:indexPath animated:YES];
                           }];
    } else {
        [self performSegueWithIdentifier:kPushDocumentsIdentifier sender:self.folders[indexPath.row]];
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
            SHCFolder *folder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];

            if ([[folder.name lowercaseString] isEqualToString:[kFolderInboxName lowercaseString]]) {
                self.inboxFolder = folder;
            } else {
                [self.folders addObject:folder];
            }
        }
    }
}

#pragma mark - Private methods

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber*) userDidInititateRequest
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
    [self.navigationItem setHidesBackButton:YES];

    self.navigationItem.title = self.rootResource.firstName ?: @"";
}

- (void)uploadProgressDidStart:(NSNotification *)notification
{
    UIViewController *topViewController = [self.navigationController topViewController];
    SHCDocumentsViewController *archiveViewController = (SHCDocumentsViewController *)topViewController;
    
    if (!([topViewController isKindOfClass:[SHCDocumentsViewController class]] && [archiveViewController.folderName isEqualToString:kFolderArchiveName])) {
    
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:NO];
        // @TODO  enure you got the correct VC !!!!!!!!
        for (SHCFolder *folder in self.folders) {
            if ([[folder.name lowercaseString] isEqualToString:[kFolderArchiveName lowercaseString]]) {
                [self performSegueWithIdentifier:kPushDocumentsIdentifier sender:folder];
            }
        }
    }
}

@end
