//
//  SHCBaseTableViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
#import "SHCBaseTableViewController.h"
#import "SHCModelManager.h"
#import "SHCRootResource.h"
#import "UIViewController+NeedsReload.h"
#import "SHCFoldersViewController.h"
#import "SHCDocumentsViewController.h"
#import "SHCReceiptsViewController.h"
#import "SHCLetterViewController.h"

@interface SHCBaseTableViewController () <NSFetchedResultsControllerDelegate>

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

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];

    // Set the initial refresh control text
    [self initializeRefreshControlText];
    [self updateRefreshControlTextRefreshing:YES];

    if ([self isKindOfClass:[SHCDocumentsViewController class]] ||
        [self isKindOfClass:[SHCReceiptsViewController class]]) {
        self.refreshControl.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];
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

    [self setEditing:NO animated:NO];

    // Sometimes, the previously selected cell isn't properly deselected.
    // The line below makes sure the cell is deselected, plus it adds a
    // fancy fading effect when the user swipes back to this view controller
    NSIndexPath *indexPathForSelectedRow = [self.tableView indexPathForSelectedRow];
    if (indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:indexPathForSelectedRow animated:YES];
    }

    // Since this is a UITableViewController subclass, and we can't subclass the GAITrackedViewController,
    // we'll manually track and submit screen hits.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    // This screen name value will remain set on the tracker and sent with hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:self.screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

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
                SHCLetterViewController *letterViewController = (SHCLetterViewController *)navigationController.topViewController;
                if ([letterViewController isKindOfClass:[SHCLetterViewController class]]) {
                    [letterViewController updateLeftBarButtonItem:nil forViewController:self];
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

- (SHCRootResource *)rootResource
{
    if (!_rootResource) {
        _rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
    }

    return _rootResource;
}

#pragma mark - Private methods

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber*) userDidInititateRequest
{
    NSAssert(NO, @"This method needs to be overridden in subclass");
}

- (void)updateNavbar
{
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:nil
                                                                         action:nil];

    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)updateFetchedResultsController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = self.baseEntity;
    fetchRequest.sortDescriptors = self.sortDescriptors;
    fetchRequest.predicate = self.predicate;

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[SHCModelManager sharedManager].managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;

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

- (void)initializeRefreshControlText
{
    NSDictionary *attributes = nil;
    if ([self isKindOfClass:[SHCDocumentsViewController class]] ||
        [self isKindOfClass:[SHCReceiptsViewController class]]) {
        attributes = @{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.4 alpha:1.0]};
    } else {
        attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    }

    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
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

        NSString *lastUpdatedDate = [dateFormatter stringFromDate:[[SHCModelManager sharedManager] rootResourceCreatedAt]];
        lastUpdatedDate = lastUpdatedDate ?: NSLocalizedString(@"GENERIC_UPDATED_NEVER_TITLE", @"never");

        text = [NSString stringWithFormat:@"%@: %@", lastUpdatedText, lastUpdatedDate];
    }

    NSDictionary *attributes = [self.refreshControl.attributedTitle attributesAtIndex:0 effectiveRange:NULL];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
