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

#import "SHCBaseTableViewController.h"
#import "POSModelManager.h"
#import "POSRootResource.h"
#import "UIViewController+NeedsReload.h"
#import "POSFoldersViewController.h"
#import "POSDocumentsViewController.h"
#import "UIViewController+BackButton.h"
#import "POSLetterViewController.h"
#import "SHCAppDelegate.h"
#import "Digipost-Swift.h"

@interface SHCBaseTableViewController () <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation SHCBaseTableViewController

@synthesize rootResource = _rootResource;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];

    // This line makes the tableview hide its separator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setCancelsTouchesInView:NO];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.layer.zPosition = -1;
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlDidChangeValue:)
                  forControlEvents:UIControlEventValueChanged];

    // Set the initial refresh control text
    [self initializeRefreshControlText];
    [self updateRefreshControlTextRefreshing:YES];

    if ([self isKindOfClass:[POSDocumentsViewController class]]) {
        self.refreshControl.tintColor = [UIColor colorWithWhite:0.4
                                                          alpha:1.0];
    } else {
        self.refreshControl.tintColor = [UIColor whiteColor];
    }

    // This is a hack to force iOS to make up its mind as to what the value of the refreshControl's frame.origin.y should be.
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];

    // Present persistent data before updating
    [self updateFetchedResultsController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![OAuthToken isUserLoggedIn]){
        SHCAppDelegate *appDelegate = (id)[UIApplication sharedApplication].delegate;
        [appDelegate showLoginView];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    // Sometimes, the previously selected cell isn't properly deselected.
    // The line below makes sure the cell is deselected, plus it adds a
    // fancy fading effect when the user swipes back to this view controller
    NSIndexPath *indexPathForSelectedRow = [self.tableView indexPathForSelectedRow];
    if (indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:indexPathForSelectedRow
                                      animated:YES];
    }

    if (self.needsReload) {
        self.needsReload = NO;
        [self updateFetchedResultsController];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.view.window.rootViewController;
        if ([splitViewController isKindOfClass:[UISplitViewController class]]) {
            UINavigationController *navigationController = (UINavigationController *)[splitViewController.viewControllers lastObject];
            if ([navigationController isKindOfClass:[UINavigationController class]]) {
                POSLetterViewController *letterViewController = (POSLetterViewController *)navigationController.topViewController;
                if ([letterViewController isKindOfClass:[POSLetterViewController class]]) {
                    [letterViewController updateLeftBarButtonItem:nil
                                                forViewController:self];
                }
            }
        }
    }

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sections = [self.fetchedResultsController sections];

    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];

    return [sectionInfo numberOfObjects];
}

#pragma mark - Properties

- (POSRootResource *)rootResource
{
    if (!_rootResource) {
        _rootResource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    }

    return _rootResource;
}

#pragma mark - Private methods

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *)userDidInititateRequest
{
    NSAssert(NO, @"This method needs to be overridden in subclass");
}

-(void)updateNavbar{
    NSAssert(NO, @"This method needs to be overridden in subclass");
}

- (void)popViewController
{
    NSAssert(self.navigationController != nil, @"no nav controller");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateFetchedResultsController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = self.baseEntity;
    fetchRequest.sortDescriptors = self.sortDescriptors;
    fetchRequest.predicate = self.predicate;
    NSAssert(self.sortDescriptors != nil, @"No sort descriptors present");
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[POSModelManager sharedManager].managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
    }

    // Because we don't know which subclass inherits from the base controller,
    // let's see if it responds to the updateFolders selector
    if ([self respondsToSelector:@selector(updateFolders)]) {
        [self performSelector:@selector(updateFolders)];
    }

    [self.tableView reloadData];
}

- (void)programmaticallyEndRefresh
{
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }

    [self updateRefreshControlTextRefreshing:NO];
}

- (void)refreshControlDidChangeValue:(UIRefreshControl *)refreshControl
{
    [self updateRefreshControlTextRefreshing:YES];

    [self updateContentsFromServerUserInitiatedRequest:@YES];
}

- (void)initializeRefreshControlText
{
    NSDictionary *attributes = nil;
    if ([self isKindOfClass:[POSDocumentsViewController class]]) {
        attributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.4
                                                                          alpha:1.0]};
    } else {
        attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }

    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@" "
                                                                          attributes:attributes];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)updateRefreshControlTextRefreshing:(BOOL)refreshing
{
    NSString *text = nil;
    if (refreshing) {
        text = NSLocalizedString(@"GENERIC_UPDATING_TITLE", @"Updating...");
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;

        NSString *lastUpdatedText = NSLocalizedString(@"GENERIC_LAST_UPDATED_TITLE", @"Last updated");

        NSString *lastUpdatedDate = [dateFormatter stringFromDate:[[POSModelManager sharedManager] rootResourceCreatedAt]];
        lastUpdatedDate = lastUpdatedDate ?: NSLocalizedString(@"GENERIC_UPDATED_NEVER_TITLE", @"never");

        text = [NSString stringWithFormat:@"%@: %@", lastUpdatedText, lastUpdatedDate];
    }

    NSDictionary *attributes = [self.refreshControl.attributedTitle attributesAtIndex:0
                                                                       effectiveRange:NULL];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:text
                                                                          attributes:attributes];
}

@end
