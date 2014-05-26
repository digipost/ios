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
#import "SHCAppDelegate.h"
#import "SHCLoginViewController.h"
#import <UIAlertView+Blocks.h>
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
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    //
    //    UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"sdfasj"
    //                                                                           style:UIBarButtonItemStyleDone
    //                                                                          target:nil
    //                                                                          action:nil];
    ////    [self.navigationItem setLeftBarButtonItem:emptyBarButtonItem];
    //    [self.navigationItem setHidesBackButton:YES];

    [self.navigationItem setLeftBarButtonItem:self.logoutBarButtonItem];

    self.dataSource = [[POSAccountViewTableViewDataSource alloc] initAsDataSourceForTableView:self.tableView];

    // hack to set title and back button when the view was instantiated programmatically instead of by user
    UIViewController *firstVC = self.navigationController.viewControllers[0];
    [firstVC.navigationItem setLeftBarButtonItem:self.logoutBarButtonItem];
    [firstVC.navigationItem setTitle:self.navigationItem.title];
    [firstVC.navigationItem setTitleView:nil];
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
        
//        [self programmaticallyEndRefresh];
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
