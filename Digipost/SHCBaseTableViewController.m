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

#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
#import "SHCBaseTableViewController.h"
#import "POSModelManager.h"
#import "POSRootResource.h"
#import "UIViewController+NeedsReload.h"
#import "SHCFoldersViewController.h"
#import "SHCDocumentsViewController.h"
#import "SHCReceiptFoldersTableViewController.h"
#import "UIViewController+BackButton.h"
#import "SHCLetterViewController.h"

@interface SHCBaseTableViewController () <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation SHCBaseTableViewController

@synthesize rootResource = _rootResource;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateNavbar];

    // This line makes the tableview hide its separator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setCancelsTouchesInView:NO];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlDidChangeValue:)
                  forControlEvents:UIControlEventValueChanged];

    // Set the initial refresh control text
    [self initializeRefreshControlText];
    [self updateRefreshControlTextRefreshing:YES];

    if ([self isKindOfClass:[SHCDocumentsViewController class]] ||
        [self isKindOfClass:[SHCReceiptFoldersTableViewController class]]) {
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

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    // Sometimes, the previously selected cell isn't properly deselected.
    // The line below makes sure the cell is deselected, plus it adds a
    // fancy fading effect when the user swipes back to this view controller
    NSIndexPath *indexPathForSelectedRow = [self.tableView indexPathForSelectedRow];
    if (indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:indexPathForSelectedRow
                                      animated:YES];
    }

    // Since this is a UITableViewController subclass, and we can't subclass the GAITrackedViewController,
    // we'll manually track and submit screen hits.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    // This screen name value will remain set on the tracker and sent with hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:self.screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

    if (self.needsReload) {
        self.needsReload = NO;
        [self updateFetchedResultsController];
    }
    [self updateNavbar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.view.window.rootViewController;
        if ([splitViewController isKindOfClass:[UISplitViewController class]]) {
            UINavigationController *navigationController = (UINavigationController *)[splitViewController.viewControllers lastObject];
            if ([navigationController isKindOfClass:[UINavigationController class]]) {
                SHCLetterViewController *letterViewController = (SHCLetterViewController *)navigationController.topViewController;
                if ([letterViewController isKindOfClass:[SHCLetterViewController class]]) {
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
// done
- (void)updateNavbar
{
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(popViewController)];

    if ([self isKindOfClass:[SHCFoldersViewController class]]) {
        self.navigationItem.backBarButtonItem = backBarButtonItem;
    }
}
// done
- (void)popViewController
{
    NSAssert(self.navigationController != nil, @"no nav controller");
    [self.navigationController popViewControllerAnimated:YES];
}

// DONE
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

    NSArray *results = [[POSModelManager sharedManager].managedObjectContext executeFetchRequest:fetchRequest
                                                                                           error:nil];

    NSLog(@"%@, results: %i", self.predicate, [results count]);

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error performing fetchedResultsController fetch: %@", [error localizedDescription]);
    }

    // Because we don't know which subclass inherits from the base controller,
    // let's see if it responds to the updateFolders selector
    if ([self respondsToSelector:@selector(updateFolders)]) {
        [self performSelector:@selector(updateFolders)];
    }

    [self.tableView reloadData];
    [self updateNavbar];
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
// done
- (void)initializeRefreshControlText
{
    NSDictionary *attributes = nil;
    if ([self isKindOfClass:[SHCDocumentsViewController class]] ||
        [self isKindOfClass:[SHCReceiptFoldersTableViewController class]]) {
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
// done
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
//    - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//
//    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//
//    UITableView *tableView = self.tableView;
//
//    switch(type) {
//
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type) {
//
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//    }
//}

@end
