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

@interface SHCBaseTableViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation SHCBaseTableViewController

@synthesize rootResource = _rootResource;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    [self updateNavbar];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];

    // Set the initial refresh control text
    [self initializeRefreshControlText];
    [self updateRefreshControlTextRefreshing:YES];

    self.refreshControl.tintColor = [UIColor whiteColor];

    // This is a hack to force iOS to make up its mind as to what the value of the refreshControl's frame.origin.y should be.
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];

    // Present persistent data before updating
    [self updateFetchedResultsController];

    [self updateContentsFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Since this is a UITableViewController subclass, and we can't subclass the GAITrackedViewController,
    // we'll manually track and submit screen hits.

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    // This screen name value will remain set on the tracker and sent with hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:self.screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

*/

#pragma mark - Properties

- (SHCRootResource *)rootResource
{
    if (!_rootResource) {
        _rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
    }

    return _rootResource;
}

#pragma mark - Private methods

- (void)updateContentsFromServer
{
    NSAssert(NO, @"This method needs to be overridden in subclass");
}

- (void)updateNavbar
{
    NSAssert(NO, @"This method needs to be overridden in subclass");
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
    self.fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error performing fetchedResultsController fetch: %@", [error localizedDescription]);
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

    [self updateContentsFromServer];
}

- (void)initializeRefreshControlText
{
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
}

- (void)updateRefreshControlTextRefreshing:(BOOL)refreshing
{
    NSString *text = nil;
    if (refreshing) {
        text = @"Updating...";
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        text = [NSString stringWithFormat:@"Last updated: %@", [dateFormatter stringFromDate:[[SHCModelManager sharedManager] rootResourceCreatedAt]]];
    }

    NSDictionary *attributes = [self.refreshControl.attributedTitle attributesAtIndex:0 effectiveRange:NULL];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
