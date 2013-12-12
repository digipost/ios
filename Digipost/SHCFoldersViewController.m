//
//  SHCFoldersViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
#import <CoreData/CoreData.h>
#import "SHCFoldersViewController.h"
#import "SHCNetworkClient.h"
#import "SHCModelManager.h"
#import "SHCFolderTableViewCell.h"
#import "SHCFolder.h"
#import "UIAlertView+Blocks.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kFoldersViewControllerIdentifier = @"FoldersViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushFoldersIdentifier = @"PushFolders";

// Google Analytics screen name
NSString *const kFoldersViewControllerScreenName = @"Folders";

@interface SHCFoldersViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SHCFoldersViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_LOGOUT_BUTTON_TITLE", @"Log Out");

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

    [self updateFoldersFromServer];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Since this is a UITableViewController subclass, and we can't subclass the GAITrackedViewController,
    // we'll manually track and submit screen hits.

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    // This screen name value will remain set on the tracker and sent with hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:kFoldersViewControllerScreenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCFolder *folder = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFolderTableViewCellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = folder.name;
    
    return cell;
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

#pragma mark - IBActions

- (IBAction)didTapLogoutButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)updateFoldersFromServer
{
    [[SHCNetworkClient sharedClient] updateRootResourceWithSuccess:^{
        [self updateFetchedResultsController];
        [self programmaticallyEndRefresh];
    } failure:^(NSError *error) {

        [self programmaticallyEndRefresh];

        [UIAlertView showWithTitle:NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error")
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[NSLocalizedString(@"GENERIC_OK_BUTTON_TITLE", @"OK")]
                          tapBlock:nil];
    }];
}

- (void)updateFetchedResultsController
{
    NSEntityDescription *entity = [[SHCModelManager sharedManager] folderEntity];
    NSManagedObjectContext *managedObjectContext = [[SHCModelManager sharedManager] managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(name)) ascending:YES selector:@selector(compare:)]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
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

    [self updateFoldersFromServer];
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
