//
//  SHCReceiptsViewController.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCReceiptsViewController.h"
#import "UIRefreshControl+Additions.h"
#import "POSReceiptsTableViewDataSource.h"
#import <UIActionSheet+Blocks.h>
#import "NSError+ExtraInfo.h"
#import "UIViewController+Additions.h"
#import <AFNetworking.h>
#import "SHCAPIManager.h"
#import "UIViewController+Additions.h"
#import "SHCReceiptTableViewCell.h"
#import "SHCReceipt.h"
#import "SHCDocumentsViewController.h"
#import <UIAlertView+Blocks.h>

@interface SHCReceiptsViewController ()
@property (nonatomic,strong)UIRefreshControl *refreshControl;
@property (nonatomic,strong)POSReceiptsTableViewDataSource *receiptsTableViewDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SHCReceiptsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:self.storeName];
    self.receiptsTableViewDataSource = [POSReceiptsTableViewDataSource new];
    self.receiptsTableViewDataSource.storeName = self.storeName;
    self.tableView.dataSource = self.receiptsTableViewDataSource;
    
    [self updateNavbar];

    // This line makes the tableview hide its separator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];

    // Set the initial refresh control text
    [self.refreshControl initializeRefreshControlText];
    [self.refreshControl updateRefreshControlTextRefreshing:YES];

    self.refreshControl.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];

    // This is a hack to force iOS to make up its mind as to what the value of the refreshControl's frame.origin.y should be.
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Present persistent data before updating
//    [self updateFetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.navigationController setToolbarHidden:!editing animated:animated];
    
    [self updateNavbar];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = !editing;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentsViewEditingStatusChangedNotificationName object:self userInfo:@{  kEditingStatusKey: [NSNumber numberWithBool:editing]}];
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


- (void)deleteReceipt:(SHCReceipt *)receipt
{
    [[SHCAPIManager sharedManager] deleteReceipt:receipt withSuccess:^{
        [self.receiptsTableViewDataSource resetFetchedResultsController];
        [self.tableView reloadData];

//        [self showTableViewBackgroundView:([self numberOfRows] == 0)];
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

//        [self showTableViewBackgroundView:([self numberOfRows] == 0)];

        [UIAlertView showWithTitle:error.errorTitle
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[error.okButtonTitle]
                          tapBlock:error.tapBlock];
    }];
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
        SHCReceipt *receipt = [self.receiptsTableViewDataSource receiptAtIndexPath:indexPathOfSelectedRow];

        [self deleteReceipt:receipt];
    }

    [self deselectAllRows];
    [self updateToolbarButtonItems];
}

- (void)updateToolbarButtonItems
{
//    if ([self.tableView indexPathsForSelectedRows] > 0) {
//        self.moveBarButtonItem.enabled = YES;
//        self.deleteBarButtonItem.enabled = YES;
//    } else {
//        self.moveBarButtonItem.enabled = NO;
//        self.deleteBarButtonItem.enabled = NO;
//    }
//    
//    if ([self someRowsSelected]) {
//        self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_NONE_TITLE", @"Select none");
//    } else {
//        self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", @"Select all");
//    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
