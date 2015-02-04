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

#import <UIActionSheet+Blocks.h>
#import <UIAlertView+Blocks.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import "POSReceiptFoldersTableViewController.h"
#import "UIRefreshControl+Additions.h"
#import "POSModelManager.h"
#import "POSReceipt.h"
#import "POSOAuthManager.h"
#import "POSLetterViewController.h"
#import "POSReceiptTableViewCell.h"
#import "SHCAppDelegate.h"
#import "NSError+ExtraInfo.h"
#import "POSDocument.h"
#import "POSRootResource.h"
#import "POSAPIManager.h"
#import "POSDocumentsViewController.h"
#import "POSReceiptFolderTableViewDataSource.h"
#import "POSReceiptsViewController.h"
#import "digipost-swift.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushReceiptsIdentifier = @"PushReceipts";
NSString *const kFolderSelectedSegueIdentifier = @"folderSelectedSegue";

// Google Analytics screen name
NSString *const kReceiptsViewControllerScreenName = @"Receipts";

@interface POSReceiptFoldersTableViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UIView *tableViewBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *noReceiptsLabel;
@property (nonatomic, strong) POSReceiptFolderTableViewDataSource *receiptFolderTableViewDataSource;

@end

@implementation POSReceiptFoldersTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [self.navigationController.toolbar setBarTintColor:[UIColor colorWithRed:64.0 / 255.0
                                                                       green:66.0 / 255.0
                                                                        blue:69.0 / 255.0
                                                                       alpha:0.95]];

    self.baseEntity = [[POSModelManager sharedManager] receiptEntity];
    self.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(timeOfPurchase))
                                                            ascending:NO
                                                             selector:@selector(compare:)] ];

    self.screenName = kReceiptsViewControllerScreenName;
    self.receiptFolderTableViewDataSource = [[POSReceiptFolderTableViewDataSource alloc] init];
    self.tableView.dataSource = self.receiptFolderTableViewDataSource;
    [self.receiptFolderTableViewDataSource refreshContent];

    // This line makes the tableview hide its separator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlDidChangeValue:)
                  forControlEvents:UIControlEventValueChanged];

    // Set the initial refresh control text
    [self.refreshControl initializeRefreshControlText];
    [self.refreshControl updateRefreshControlTextRefreshing:YES];

    self.refreshControl.tintColor = [UIColor colorWithWhite:0.4
                                                      alpha:1.0];

    // This is a hack to force iOS to make up its mind as to what the value of the refreshControl's frame.origin.y should be.
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES
                                       animated:NO];
    [self updateContentsFromServerUserInitiatedRequest:@NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[APIClient sharedClient] cancelUpdatingReceipts];

    [self programmaticallyEndRefresh];

    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushReceiptIdentifier]) {

    } else if ([segue.identifier isEqualToString:kFolderSelectedSegueIdentifier]) {
        NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
        NSString *storeName = [self.receiptFolderTableViewDataSource storeNameAtIndexPath:selectedRowIndexPath];
        POSReceiptsViewController *receiptsViewController = (id)segue.destinationViewController;
        receiptsViewController.storeName = storeName;
    }
}

- (void)refreshControlDidChangeValue:(UIRefreshControl *)refreshControl
{
    [self.refreshControl updateRefreshControlTextRefreshing:YES];

    [self updateContentsFromServerUserInitiatedRequest:@YES];
}
#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (self.isEditing) {
    //        [self updateToolbarButtonItems];
    //
    //        return;
    //    }
    //
    //    SHCReceipt *receipt = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //
    //    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    //        ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.receipt = receipt;
    //    } else {
    ////        [self performSegueWithIdentifier:kPushReceiptIdentifier sender:receipt];
    //    }
}

#pragma mark - IBActions

- (void)selectAllRows
{
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        for (NSInteger row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row
                                                        inSection:section];
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)deselectAllRows
{
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        [self.tableView deselectRowAtIndexPath:indexPath
                                      animated:NO];
    }
}

#pragma mark - Private methods

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *)userDidInititateRequest
{
    SHCAppDelegate *appDelegate = (id)[UIApplication sharedApplication].delegate;
    POSLetterViewController *letterViewConctroller = appDelegate.letterViewController;
    NSString *openedReceiptURI = letterViewConctroller.receipt.uri;

    [[APIClient sharedClient] updateReceiptsInMailboxWithDigipostAddress:self.mailboxDigipostAddress uri:self.receiptsUri success:^(NSDictionary *responseDictionary) {
            [[POSModelManager sharedManager] updateReceiptsInMailboxWithDigipostAddress:self.mailboxDigipostAddress
                                                                             attributes:responseDictionary];
            [self updateFetchedResultsController];
            [self programmaticallyEndRefresh];
            [self updateNavbar];
            if (letterViewConctroller.receipt) {
                if (letterViewConctroller.receipt.uri == nil) {
                    POSReceipt *refetchedObject = [POSReceipt existingReceiptWithUri:openedReceiptURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                    [letterViewConctroller setReceiptDoNotDismissPopover:refetchedObject];
                }
            }
            [self.receiptFolderTableViewDataSource refreshContent];
            [self.tableView reloadData];
            [self showTableViewBackgroundView:([self.receiptFolderTableViewDataSource numberOfReceiptGroups] == 0)];
    }
        failure:^(APIError *error) {
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[APIClient sharedClient] responseCodeForOAuthIsUnauthorized:response]) {
                // We were unauthorized, due to the session being invalid.
                // Let's retry in the next run loop
                [self performSelector:@selector(updateContentsFromServerUserInitiatedRequest:) withObject:userDidInititateRequest afterDelay:0.0];
                return;
            }
        }

            [self programmaticallyEndRefresh];
            [self showTableViewBackgroundView:([self.receiptFolderTableViewDataSource numberOfReceiptGroups] == 0)];

        if ([userDidInititateRequest boolValue]) {
            [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
        }
        }];
}

- (void)updateNavbar
{
    [super updateNavbar];
    self.navigationItem.title = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NAVBAR_TITLE", @"Receipts");
}

- (BOOL)someRowsSelected
{
    return [[self.tableView indexPathsForSelectedRows] count] > 0;
}

//- (NSInteger)numberOfRows
//{
//    NSInteger numberOfRows = 0;
//    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
//        numberOfRows += [self.tableView numberOfRowsInSection:section];
//    }
//
//    return numberOfRows;
//}

- (void)showTableViewBackgroundView:(BOOL)showTableViewBackgroundView
{
    if (!self.tableViewBackgroundView.superview && showTableViewBackgroundView) {
        self.tableView.backgroundView = self.tableViewBackgroundView;
    }

    if (showTableViewBackgroundView) {
        POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];

        if ([rootResource.numberOfCards integerValue] == 0) {
            self.noReceiptsLabel.text = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_NO_CARDS_TITLE", @"No cards");
        } else if ([rootResource.numberOfCardsReadyForVerification integerValue] == 0) {
            self.noReceiptsLabel.text = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_CARDS_READY_TITLE", @"Cards ready");
        } else {
            NSString *format = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_HIDDEN_TITLE", @"Receipts hidden");
            NSInteger numberOfReceiptsHidden = [rootResource.numberOfReceiptsHiddenUntilVerification integerValue];
            NSString *receiptWord = numberOfReceiptsHidden == 1 ? NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_RECEIPT_WORD_IS_SINGULAR", @"receipt is") : NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_RECEIPT_WORD_IS_PLURAL", @"receipts are");
            self.noReceiptsLabel.text = [NSString stringWithFormat:format, numberOfReceiptsHidden, receiptWord];
        }
    }

    self.tableViewBackgroundView.hidden = !showTableViewBackgroundView;
}

@end
