//
//  SHCReceiptsViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 20.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIActionSheet+Blocks.h>
#import <UIAlertView+Blocks.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import "SHCReceiptsViewController.h"
#import "SHCModelManager.h"
#import "SHCReceipt.h"
#import "SHCAPIManager.h"
#import "SHCLetterViewController.h"
#import "SHCReceiptTableViewCell.h"
#import "SHCAppDelegate.h"
#import "NSError+ExtraInfo.h"
#import "SHCDocument.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushReceiptsIdentifier = @"PushReceipts";

// Google Analytics screen name
NSString *const kReceiptsViewControllerScreenName = @"Receipts";

@interface SHCReceiptsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectionBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;

@end

@implementation SHCReceiptsViewController

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

    [self updateContentsFromServer];
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
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    [self.navigationController setToolbarHidden:!editing animated:animated];

    [self updateNavbar];

    self.navigationController.interactivePopGestureRecognizer.enabled = !editing;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCReceipt *receipt = [self.fetchedResultsController objectAtIndexPath:indexPath];

    SHCReceiptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReceiptTableViewCellIdentifier forIndexPath:indexPath];

    cell.amountLabel.text = [SHCReceipt stringForReceiptAmount:receipt.amount];
    cell.cardLabel.text = receipt.card;
    cell.storeNameLabel.text = receipt.storeName;
    cell.dateLabel.text = [SHCDocument stringForDocumentDate:receipt.timeOfPurchase];

    return cell;
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
        [self performSegueWithIdentifier:kPushReceiptIdentifier sender:receipt];
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

- (IBAction)didTapDeleteBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSUInteger numberOfReceipts = [[self.tableView indexPathsForSelectedRows] count];
    NSString *receiptWord = numberOfReceipts == 1 ? NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_SINGULAR", @"receipt") :
                                                    NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_PLURAL", @"receipts");

    NSString *deleteString = [NSString stringWithFormat:@"%@ %lu %@",
                              NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_ONE", @"Delete"),
                              (unsigned long)[[self.tableView indexPathsForSelectedRows] count],
                              receiptWord];

    [UIActionSheet showFromBarButtonItem:barButtonItem
                                animated:YES
                               withTitle:nil
                       cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
                  destructiveButtonTitle:deleteString
                       otherButtonTitles:nil
                                tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                    if (buttonIndex == 0) {
                                        [self deleteReceipts];
                                    }
                                }];
}

#pragma mark - Private methods

- (void)updateContentsFromServer
{
    if ([SHCAPIManager sharedManager].isUpdatingReceipts) {
        return;
    }

    [[SHCAPIManager sharedManager] updateReceiptsInMailboxWithDigipostAddress:self.mailboxDigipostAddress uri:self.receiptsUri success:^{
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
    self.navigationItem.title = NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_NAVBAR_TITLE", @"Receipts");

    UIBarButtonItem *rightBarButtonItem = nil;
    if ([self numberOfRows] > 0) {
        rightBarButtonItem = self.editButtonItem;
    }

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
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
        SHCReceiptTableViewCell *cell = (SHCReceiptTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)deleteReceipts
{
    for (NSIndexPath *indexPathOfSelectedRow in [self.tableView indexPathsForSelectedRows]) {
        SHCReceipt *receipt = [self.fetchedResultsController objectAtIndexPath:indexPathOfSelectedRow];

        [self deleteReceipt:receipt];
    }

    [self deselectAllRows];
    [self updateToolbarButtonItems];
}

- (void)deleteReceipt:(SHCReceipt *)receipt
{
    [[SHCAPIManager sharedManager] deleteReceipt:receipt withSuccess:^{
        [self updateFetchedResultsController];
    } failure:^(NSError *error) {

        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                // We were unauthorized, due to the session being invalid.
                // Let's retry in the next run loop
                [self performSelector:@selector(deleteReceipt:) withObject:receipt afterDelay:0.0];

                return;
            }
        }

        [UIAlertView showWithTitle:error.errorTitle
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[error.okButtonTitle]
                          tapBlock:error.tapBlock];
    }];
}

@end
