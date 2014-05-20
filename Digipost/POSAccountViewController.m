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
#import "SHCMailbox.h"

@interface POSAccountViewController ()

@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) POSAccountViewTableViewDataSource *dataSource;

@end

@implementation POSAccountViewController

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
    self.refreshControl = [[UIRefreshControl alloc]  init];
    [self.tableView addSubview:self.refreshControl];
    
    UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setLeftBarButtonItem:emptyBarButtonItem];
    [self.navigationItem setHidesBackButton:YES];
    
    self.dataSource = [[POSAccountViewTableViewDataSource alloc] initAsDataSourceForTableView:self.tableView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateContentsFromServerUserInitiatedRequest:@NO];
}

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber*) userDidInititateRequest
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
    if ([segue.identifier isEqualToString:@"PushFolders"]){
        SHCMailbox *mailbox = [self.dataSource managedObjectAtIndexPath:self.tableView.indexPathForSelectedRow];
        SHCFoldersViewController *folderViewController = (id) segue.destinationViewController;
        folderViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress;
        [SHCModelManager sharedManager].selectedMailboxDigipostAddress = mailbox.digipostAddress;
    }
}

@end
