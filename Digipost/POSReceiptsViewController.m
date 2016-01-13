//
//  SHCReceiptsViewController.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "POSReceiptsViewController.h"
#import "UIRefreshControl+Additions.h"
#import "POSReceiptsTableViewDataSource.h"
#import <UIActionSheet_Blocks/UIActionSheet+Blocks.h>
#import "NSError+ExtraInfo.h"
#import "UIViewController+Additions.h"
#import <AFNetworking/AFNetworking.h>
#import "POSLetterViewController.h"
#import "SHCAppDelegate.h"
#import "UIViewController+Additions.h"
#import "POSReceiptTableViewCell.h"
#import "POSReceipt.h"
#import "POSDocumentsViewController.h"
#import "UIViewController+BackButton.h"
#import "Digipost-Swift.h"
#import <UIAlertView_Blocks/UIAlertView+Blocks.h>

NSString *const kPushReceiptIdentifier = @"PushReceipt";

@interface POSReceiptsViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) POSReceiptsTableViewDataSource *receiptsTableViewDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectionBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@end

@implementation POSReceiptsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", @"Select all");
    self.deleteBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_DELETE_TITLE", @"Delete");
    [self.navigationItem setTitle:self.storeName];
    self.receiptsTableViewDataSource = [[POSReceiptsTableViewDataSource alloc] initAsDataSourceForTableView:self.tableView];
    self.receiptsTableViewDataSource.storeName = self.storeName;
    self.tableView.delegate = self;

    [self updateNavbar];

    // This line makes the tableview hide its separator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.refreshControl = [[UIRefreshControl alloc] init];
    //    [self.refreshControl addTarget:self
    //                            action:@selector(refreshControlDidChangeValue:)
    //                  forControlEvents:UIControlEventValueChanged];

    // Set the initial refresh control text
    [self.refreshControl initializeRefreshControlText];
    [self.refreshControl updateRefreshControlTextRefreshing:YES];

    self.refreshControl.tintColor = [UIColor colorWithWhite:0.4
                                                      alpha:1.0];

    // This is a hack to force iOS to make up its mind as to what the value of the refreshControl's frame.origin.y should be.
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Present persistent data before updating
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES
                                       animated:NO];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow
                                  animated:YES];
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.isEditing) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushReceiptIdentifier]) {
        POSReceipt *receipt = [self.receiptsTableViewDataSource receiptAtIndexPath:[self.tableView indexPathForSelectedRow]];
        POSLetterViewController *letterViewController = (POSLetterViewController *)segue.destinationViewController;
        letterViewController.receiptsViewController = (id)self;
        letterViewController.receipt = receipt;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing
             animated:animated];

    [self.navigationController setToolbarHidden:!editing
                                       animated:animated];

    [self updateNavbar];
    [self.tableView setEditing:editing
                      animated:animated];

    self.navigationController.interactivePopGestureRecognizer.enabled = !editing;

    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentsViewEditingStatusChangedNotificationName
                                                        object:self
                                                      userInfo:@{kEditingStatusKey : [NSNumber numberWithBool:editing]}];
}

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
    NSString *receiptWord = numberOfReceipts == 1 ? NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_SINGULAR", @"receipt") : NSLocalizedString(@"RECEIPTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_PLURAL", @"receipts");

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

- (void)deleteReceipt:(POSReceipt *)receipt
{
    [[APIClient sharedClient] deleteReceipt:receipt success:^{
                                         [self.receiptsTableViewDataSource resetFetchedResultsController];
                                         [self.tableView reloadData];
    }
        failure:^(APIError *error) {
            [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
        }];
}

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
        POSReceiptTableViewCell *cell = (POSReceiptTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        [self.tableView deselectRowAtIndexPath:indexPath
                                      animated:NO];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {
        [self updateToolbarButtonItems];
        return;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {

        [self updateToolbarButtonItems];

        return;
    }

    POSReceipt *receipt = [self.receiptsTableViewDataSource receiptAtIndexPath:indexPath];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        SHCAppDelegate *appDelegate = (id)[UIApplication sharedApplication].delegate;
        appDelegate.letterViewController.receipt = receipt;
    } else {
        [self performSegueWithIdentifier:kPushReceiptIdentifier
                                  sender:self];
    }
}

- (void)deleteReceipts
{
    __block NSInteger numberOfDocumentsRemaining = [self.tableView indexPathsForSelectedRows].count;
    for (NSIndexPath *indexPathOfSelectedRow in [self.tableView indexPathsForSelectedRows]) {
        POSReceipt *receipt = [self.receiptsTableViewDataSource receiptAtIndexPath:indexPathOfSelectedRow];
        [[APIClient sharedClient] deleteReceipt:receipt success:^{
            [[POSModelManager sharedManager] deleteReceipt:receipt];
            [[POSModelManager sharedManager] logSavingManagedObjectContext];
            numberOfDocumentsRemaining -= 1;
            if (numberOfDocumentsRemaining == 0) {
//                [self.receiptsTableViewDataSource resetFetchedResultsController];
//                [self.tableView reloadData];
                [self deselectAllRows];
            }
        } failure:^(APIError *error) {
            [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
            [self.receiptsTableViewDataSource resetFetchedResultsController];
            [self.tableView reloadData];
            [self deselectAllRows];
        }];
    }

    [self updateToolbarButtonItems];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)someRowsSelected
{
    return [[self.tableView indexPathsForSelectedRows] count] > 0;
}

@end
