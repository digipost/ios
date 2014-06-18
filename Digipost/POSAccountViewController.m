//
//  POSAccountViewController.m
//  Digipost
//
//  Created by Håkon Bogen on 19.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSAccountViewController.h"
#import "POSAccountViewTableViewDataSource.h"
#import "SHCFoldersViewController.h"
#import "SHCAPIManager.h"
#import <AFNetworking/AFNetworking.h>
#import "UIRefreshControl+Additions.m"
#import "POSMailbox.h"
#import <UIActionSheet+Blocks.h>
#import "SHCLetterViewController.h"
#import "UIViewController+BackButton.h"
#import "SHCAppDelegate.h"
#import "SHCLoginViewController.h"
#import "POSFolder+Methods.h"
#import <UIAlertView+Blocks.h>
#import "POSRootResource.h"
#import "SHCOAuthManager.h"
#import "NSError+ExtraInfo.h"

NSString *const kAccountViewControllerIdentifier = @"accountViewController";
@interface POSAccountViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
- (IBAction)logoutButtonTapped:(id)sender;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) POSAccountViewTableViewDataSource *dataSource;

@end

@implementation POSAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];

    self.dataSource = [[POSAccountViewTableViewDataSource alloc] initAsDataSourceForTableView:self.tableView];

    // hack to set title and back button when the view was instantiated programmatically instead of by user
    UIViewController *firstVC = self.navigationController.viewControllers[0];
    if (firstVC.navigationItem.rightBarButtonItem == nil) {
        [firstVC.navigationItem setRightBarButtonItem:self.logoutBarButtonItem];
    }
    firstVC.navigationItem.leftBarButtonItem = nil;
    firstVC.navigationItem.backBarButtonItem = nil;
    [firstVC.navigationItem setTitleView:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        if (rootResource) {
            [self performSegueWithIdentifier:@"gotoDocumentsFromAccountsSegue"
                                      sender:self];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *title = NSLocalizedString(@"Accounts title", @"Title for navbar at accounts view");
    UINavigationItem *showingItem = self.navigationController.navigationBar.backItem;
    [showingItem setHidesBackButton:YES];
    if ([showingItem respondsToSelector:@selector(setLeftBarButtonItem:)]) {
        [showingItem setLeftBarButtonItem:nil];
    }
    if ([showingItem respondsToSelector:@selector(setRightBarButtonItem:)]) {
        [showingItem setRightBarButtonItem:self.logoutBarButtonItem];
    }

    if ([showingItem respondsToSelector:@selector(setBackBarButtonItem:)]) {
        [showingItem setBackBarButtonItem:nil];
    }
    [showingItem setTitle:title];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationController.navigationBar.topItem setRightBarButtonItem:self.logoutBarButtonItem];
    [self.navigationController.navigationBar.topItem setTitle:title];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateContentsFromServerUserInitiatedRequest:@NO];
}

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *)userDidInititateRequest
{
    if ([SHCAPIManager sharedManager].isUpdatingRootResource) {
        return;
    }

    [[SHCAPIManager sharedManager] updateRootResourceWithSuccess:^{
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
        
        if ([userDidInititateRequest boolValue]) {
//            [UIAlertView showWithTitle:error.errorTitle
//                               message:[error localizedDescription]
//                     cancelButtonTitle:nil
//                     otherButtonTitles:@[error.okButtonTitle]
//                              tapBlock:error.tapBlock];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushFolders"]) {
        POSMailbox *mailbox = [self.dataSource managedObjectAtIndexPath:self.tableView.indexPathForSelectedRow];
        SHCFoldersViewController *folderViewController = (id)segue.destinationViewController;
        folderViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress;
        [POSModelManager sharedManager].selectedMailboxDigipostAddress = mailbox.digipostAddress;
    } else if ([segue.identifier isEqualToString:@"gotoDocumentsFromAccountsSegue"]) {
        SHCDocumentsViewController *documentsView = (id)segue.destinationViewController;
        POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"owner"
                                                                       ascending:YES];
        NSArray *mailboxes = [rootResource.mailboxes sortedArrayUsingDescriptors:
                                                         @[ nameDescriptor ]];
        POSMailbox *userMailbox = mailboxes[0];
        documentsView.mailboxDigipostAddress = userMailbox.digipostAddress;
        documentsView.folderName = kFolderInboxName;
    }
}

- (IBAction)logoutButtonTapped:(id)sender
{
    [self logoutUser];
}

#pragma mark logout
- (void)logoutUser
{

    [UIActionSheet showFromBarButtonItem:self.logoutBarButtonItem
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
                                       [[POSModelManager sharedManager] deleteAllObjects];

                                   } failure:^(NSError *error) {

                                       [[SHCOAuthManager sharedManager] removeAllTokens];
                                       [[POSModelManager sharedManager] deleteAllObjects];

                                       [UIAlertView showWithTitle:error.errorTitle
                                                          message:[error localizedDescription]
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@[error.okButtonTitle]
                                                         tapBlock:error.tapBlock];
                                   }];
                               }
                                }];
}
@end
