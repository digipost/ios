//
//  SHCFoldersViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIAlertView+Blocks.h>
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

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kFoldersViewControllerIdentifier = @"FoldersViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushFoldersIdentifier = @"PushFolders";

// Google Analytics screen name
NSString *const kFoldersViewControllerScreenName = @"Folders";

@interface SHCFoldersViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) SHCFolder *inboxFolder;
@property (strong, nonatomic) NSMutableArray *folders;

@end

@implementation SHCFoldersViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.baseEntity = [[SHCModelManager sharedManager] folderEntity];
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(name))
                                                           ascending:YES
                                                            selector:@selector(compare:)]];

    self.predicate = [NSPredicate predicateWithFormat:@"%K == YES", [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(mailbox)), NSStringFromSelector(@selector(owner))]];

    self.screenName = kFoldersViewControllerScreenName;

    self.folders = [NSMutableArray array];

    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressDidStart:) name:kAPIManagerUploadProgressStartedNotificationName object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateContentsFromServer];
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
        documentsViewController.folderUri = folder.uri;
    } else if ([segue.identifier isEqualToString:kPushReceiptsIdentifier]) {
        SHCReceiptsViewController *receiptsViewController = (SHCReceiptsViewController *)segue.destinationViewController;
        receiptsViewController.mailboxDigipostAddress = self.inboxFolder.mailbox.digipostAddress;
        receiptsViewController.receiptsUri = self.inboxFolder.mailbox.receiptsUri;
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

    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return [self.folders count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *folderName = nil;
    UIImage *iconImage = nil;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            folderName = self.inboxFolder.name;
            iconImage = [UIImage imageNamed:@"list-icon-inbox"];
        } else {
            folderName = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_RECEIPTS_TITLE", @"Receipts");
            iconImage = [UIImage imageNamed:@"list-icon-receipt"];
        }
    } else {
        folderName = [self.folders[indexPath.row] name];
        iconImage = [UIImage imageNamed:@"list-icon-folder"];
    }

    SHCFolderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFolderTableViewCellIdentifier forIndexPath:indexPath];
    cell.folderNameLabel.text = folderName;
    cell.iconImageView.image = iconImage;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 1) {
        title = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_FOLDERS_SECTION_HEADER_TITLE", @"FOLDERS");
    }

    return title;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.0;
    if (section > 0) {
        height = self.tableView.sectionHeaderHeight;
    }

    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor colorWithRed:64.0/255.0 green:66.0/255.0 blue:69.0/255.0 alpha:1.0];

    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    headerFooterView.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    headerFooterView.textLabel.textColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:kPushDocumentsIdentifier sender:self.inboxFolder];
        } else {
            [self performSegueWithIdentifier:kPushReceiptsIdentifier sender:nil];
        }
    } else {
        [self performSegueWithIdentifier:kPushDocumentsIdentifier sender:self.folders[indexPath.row]];
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

#pragma mark - IBActions

- (IBAction)didTapLogoutButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPopToLoginViewControllerNotificationName object:nil];

    [[SHCAPIManager sharedManager] logoutWithSuccess:^{
        [[SHCOAuthManager sharedManager] removeAllTokens];
    } failure:^(NSError *error) {
        [UIAlertView showWithTitle:error.errorTitle
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[error.okButtonTitle]
                          tapBlock:error.tapBlock];
    }];
}

#pragma mark - Private methods

- (void)updateContentsFromServer
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
                [self performSelector:@selector(updateContentsFromServer) withObject:nil afterDelay:0.0];

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
    [super updateNavbar];

    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_LOGOUT_BUTTON_TITLE", @"Sign Out");
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.8]} forState:UIControlStateNormal];

    self.navigationItem.title = self.rootResource.firstName ?: @"";
}

- (void)uploadProgressDidStart:(NSNotification *)notification
{
    UIViewController *topViewController = [self.navigationController topViewController];
    SHCDocumentsViewController *archiveViewController = (SHCDocumentsViewController *)topViewController;
    if (!([topViewController isKindOfClass:[SHCDocumentsViewController class]] && [archiveViewController.folderName isEqualToString:kFolderArchiveName])) {

        [self.navigationController popToViewController:self animated:YES];

        for (SHCFolder *folder in self.folders) {
            if ([[folder.name lowercaseString] isEqualToString:[kFolderArchiveName lowercaseString]]) {
                [self performSegueWithIdentifier:kPushDocumentsIdentifier sender:folder];
            }
        }
    }
}

@end
