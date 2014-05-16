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
#import "SHCReceiptFoldersTableViewController.h"
#import "SHCModelManager.h"
#import "SHCReceipt.h"
#import "SHCAPIManager.h"
#import "SHCLetterViewController.h"
#import "SHCReceiptTableViewCell.h"
#import "SHCAppDelegate.h"
#import "NSError+ExtraInfo.h"
#import "SHCDocument.h"
#import "SHCRootResource.h"
#import "SHCDocumentsViewController.h"
#import "SHCReceiptFolderTableViewDataSource.h"
#import "SHCReceiptsViewController.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushReceiptsIdentifier = @"PushReceipts";
NSString *const kFolderSelectedSegueIdentifier = @"folderSelectedSegue";

// Google Analytics screen name
NSString *const kReceiptsViewControllerScreenName = @"Receipts";

@interface SHCReceiptFoldersTableViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectionBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView *tableViewBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *noReceiptsLabel;
@property (nonatomic,strong) SHCReceiptFolderTableViewDataSource *receiptFolderTableViewDataSource;

@end

@implementation SHCReceiptFoldersTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [self.navigationController.toolbar setBarTintColor:[UIColor colorWithRed:64.0/255.0 green:66.0/255.0 blue:69.0/255.0 alpha:0.95]];

    self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", @"Select all");
    self.deleteBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_DELETE_TITLE", @"Delete");

    self.baseEntity = [[SHCModelManager sharedManager] receiptEntity];
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(timeOfPurchase))
                                                           ascending:NO
                                                            selector:@selector(compare:)]];

    self.screenName = kReceiptsViewControllerScreenName;
    self.receiptFolderTableViewDataSource = [[SHCReceiptFolderTableViewDataSource alloc] init];
    self.tableView.dataSource = self.receiptFolderTableViewDataSource;
    [self.receiptFolderTableViewDataSource refreshContent];

    [super viewDidLoad];

    [self updateToolbarButtonItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateContentsFromServerUserInitiatedRequest:@NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SHCAPIManager sharedManager] cancelUpdatingReceipts];

    [self programmaticallyEndRefresh];

    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushReceiptIdentifier]) {
        SHCReceipt *receipt = (SHCReceipt *)sender;

        SHCLetterViewController *letterViewController = (SHCLetterViewController *)segue.destinationViewController;
        letterViewController.receiptsViewController = self;
        letterViewController.receipt = receipt;
    }else if ([segue.identifier isEqualToString:kFolderSelectedSegueIdentifier]){
        NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
        NSString *storeName =[self.receiptFolderTableViewDataSource storeNameAtIndexPath:selectedRowIndexPath];
        SHCReceiptsViewController *receiptsViewController = (id) segue.destinationViewController;
        receiptsViewController.storeName = storeName;
    }
}




#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {
        [self updateToolbarButtonItems];

        return;
    }

    SHCReceipt *receipt = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.receipt = receipt;
    } else {
//        [self performSegueWithIdentifier:kPushReceiptIdentifier sender:receipt];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {
        [self updateToolbarButtonItems];
        return;
    }
}

#pragma mark - IBActions

- (IBAction)didTapSelectionBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if ([self someRowsSelected]) {
        [self deselectAllRows];
    } else {
        [self selectAllRows];
    }

    [self updateToolbarButtonItems];
}
- (void)selectAllRows
{
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        for (NSInteger row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
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
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Private methods

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *) userDidInititateRequest
{
    if ([SHCAPIManager sharedManager].isUpdatingReceipts) {
        return;
    }
    SHCAppDelegate *appDelegate = (id) [UIApplication sharedApplication].delegate;
    SHCLetterViewController *letterViewConctroller = appDelegate.letterViewController;
    NSString *openedReceiptURI = letterViewConctroller.receipt.uri;

    
    
    [[SHCAPIManager sharedManager] updateReceiptsInMailboxWithDigipostAddress:self.mailboxDigipostAddress uri:self.receiptsUri success:^{
        [self updateFetchedResultsController];
        [self programmaticallyEndRefresh];
        [self updateNavbar];

        if (letterViewConctroller.receipt) {
            if (letterViewConctroller.receipt.uri == nil) {
                SHCReceipt *refetchedObject = [SHCReceipt existingReceiptWithUri:openedReceiptURI inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
                [letterViewConctroller setReceiptDoNotDismissPopover:refetchedObject];
            }
        }
        [self showTableViewBackgroundView:([self numberOfRows] == 0)];
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

        [self showTableViewBackgroundView:([self numberOfRows] == 0)];
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
    self.navigationItem.title = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NAVBAR_TITLE", @"Receipts");
}

- (void)updateToolbarButtonItems
{
    if ([self.tableView indexPathsForSelectedRows] > 0) {
        self.deleteBarButtonItem.enabled = YES;
    } else {
        self.deleteBarButtonItem.enabled = NO;
    }

    if ([self someRowsSelected]) {
        self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_NONE_TITLE", @"Select none");
    } else {
        self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", @"Select all");
    }
}

- (BOOL)someRowsSelected
{
    return [[self.tableView indexPathsForSelectedRows] count] > 0;
}

- (NSInteger)numberOfRows
{
    NSInteger numberOfRows = 0;
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        numberOfRows += [self.tableView numberOfRowsInSection:section];
    }

    return numberOfRows;
}

- (void)showTableViewBackgroundView:(BOOL)showTableViewBackgroundView
{
    if (!self.tableViewBackgroundView.superview && showTableViewBackgroundView) {
        self.tableView.backgroundView = self.tableViewBackgroundView;
    }

    if (showTableViewBackgroundView) {
        SHCRootResource *rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];

        if ([rootResource.numberOfCards integerValue] == 0) {
            self.noReceiptsLabel.text = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_NO_CARDS_TITLE", @"No cards");
        } else if ([rootResource.numberOfCardsReadyForVerification integerValue] == 0) {
            self.noReceiptsLabel.text = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_CARDS_READY_TITLE", @"Cards ready");
        } else {
            NSString *format = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_HIDDEN_TITLE", @"Receipts hidden");
            NSInteger numberOfReceiptsHidden = [rootResource.numberOfReceiptsHiddenUntilVerification integerValue];
            NSString *receiptWord = numberOfReceiptsHidden == 1 ? NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_RECEIPT_WORD_IS_SINGULAR", @"receipt is") :
                                                                  NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_RECEIPT_WORD_IS_PLURAL", @"receipts are");
            self.noReceiptsLabel.text = [NSString stringWithFormat:format, numberOfReceiptsHidden, receiptWord];
        }
    }

    self.tableViewBackgroundView.hidden = !showTableViewBackgroundView;
}


@end
