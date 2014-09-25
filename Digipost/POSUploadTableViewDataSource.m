//
//  POSUploadTableViewDataSource.m
//  Digipost
//
//  Created by Håkon Bogen on 09.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSUploadTableViewDataSource.h"
#import "POSFolderTableViewCell.h"
#import "POSModelManager.h"
#import "POSFolder+Methods.h"
#import <CoreData/CoreData.h>
#import "POSMailbox.h"

@interface POSUploadTableViewDataSource ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation POSUploadTableViewDataSource

- (id)initAsDataSourceForTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        tableView.dataSource = self;
        _fetchedResultsController.delegate = self;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id objectInFetchedResultsController = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell;
    if ([objectInFetchedResultsController isKindOfClass:[POSFolder class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCellIdentifier" forIndexPath:indexPath];
        POSFolder *folder = (id)objectInFetchedResultsController;
        POSFolderTableViewCell *foldercell = (id) cell;
        foldercell.folderNameLabel.text = folder.displayName;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        POSMailbox *mailbox = (id)objectInFetchedResultsController;
        cell.textLabel.text = mailbox.name;
    }

    return cell;
}

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell with objects from your store
    POSMailbox *objectInFetchedResultsController = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([objectInFetchedResultsController isKindOfClass:[POSFolder class]]) {
        POSFolder *folder = (id)objectInFetchedResultsController;
        cell.textLabel.text = folder.displayName;
    } else {
        POSMailbox *mailbox = (id)objectInFetchedResultsController;
        cell.textLabel.text = mailbox.name;
    }
}

// convenience method for fetching objects at index path from the database
- (id)managedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    POSMailbox *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return managedObject;
}

- (NSFetchRequest *)fetchRequest
{
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *managedObjectContext = [POSModelManager sharedManager].managedObjectContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

    [fetchRequest setSortDescriptors:@[ nameDescriptor ]];
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    // Order the events by creation date, most recent first.

    // Create and initialize the fetch results controller.

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest] managedObjectContext:[POSModelManager sharedManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    [_fetchedResultsController performFetch:&error];

    if (error) {
        NSLog(@"%@", error);
    }

    return _fetchedResultsController;
}

#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{

    UITableView *tableView = self.tableView;

    switch (type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{

    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
