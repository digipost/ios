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
#import "POSFolderIcon.h"
#import "POSMailbox+Methods.h"

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
        cell.backgroundColor = RGB(64, 66, 69);

    } else {
        POSMailbox *mailbox = (id)objectInFetchedResultsController;
        if (mailbox.owner.boolValue) {
            UINib *cellNib = [UINib nibWithNibName:@"MainAccountTableViewCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:@"mainAccountCellIdentifier"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"mainAccountCellIdentifier" forIndexPath:indexPath];


        } else {
            UINib *cellNib = [UINib nibWithNibName:@"AccountTableViewCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:@"accountCellIdentifier"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"accountCellIdentifier" forIndexPath:indexPath];

        }
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell with objects from your store
    POSMailbox *objectInFetchedResultsController = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([objectInFetchedResultsController isKindOfClass:[POSFolder class]]) {
        POSFolder *folder = (id)objectInFetchedResultsController;
        POSFolderTableViewCell *foldercell = (id)cell;
        foldercell.folderNameLabel.text = folder.displayName;
        POSFolderIcon *folderIcon = [POSFolderIcon folderIconWithName:folder.iconName];
        UIImage *iconImage = folderIcon.smallImage;
        if (iconImage == nil) {
            iconImage = [UIImage imageNamed:@"list-icon-inbox"];
        }
        foldercell.iconImageView.image = iconImage;
    } else {

        POSMailbox *mailbox = (id)objectInFetchedResultsController;

        NSString *unreadItemsString = @"";

        if (mailbox.unreadItemsInInbox.intValue == 1) {
            NSString *str = NSLocalizedString(@"account view unread letter", @"Unread message");
            unreadItemsString = [NSString stringWithFormat:@"%@ %@", mailbox.unreadItemsInInbox, str];
        } else {
            NSString *str = NSLocalizedString(@"account view unread letters", @"Unread messages");
            unreadItemsString = [NSString stringWithFormat:@"%@ %@", mailbox.unreadItemsInInbox, str];
        }

        if ([cell isKindOfClass:[MainAccountTableViewCell class]]) {
            MainAccountTableViewCell *mainCell = (MainAccountTableViewCell *)cell;
            mainCell.accountNameLabel.text = mailbox.name;
            mainCell.initialLabel.text = mailbox.name.initials;
            mainCell.unreadMessages.text = unreadItemsString;

        } else if ([cell isKindOfClass:[AccountTableViewCell class]]) {
            AccountTableViewCell *accCell = (AccountTableViewCell *)cell;
            accCell.accountNameLabel.text = mailbox.name;
            accCell.initialLabel.text = mailbox.name.initials;
            accCell.unreadMessages.text = unreadItemsString;
            accCell.accountDescriptionLabel.text = NSLocalizedString(@"account description shared", @"Shared with you");
        }
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
    fetchRequest.predicate = [self predicate];

    fetchRequest.sortDescriptors = [self sortDescriptors];

    return fetchRequest;
}

- (NSArray *)sortDescriptors
{
    if ([self.entityDescription isEqualToString:kFolderEntityName]) {
        NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        return @[indexDescriptor];
    } else {
        NSSortDescriptor *ownerDescriptor = [[NSSortDescriptor alloc] initWithKey:@"owner"
                                                                        ascending:NO];
        
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                       ascending:YES];
        return @[ownerDescriptor, nameDescriptor];
    }
}

- (NSPredicate *)predicate
{
    if (self.selectedMailboxDigipostAddress) {
        POSMailbox *mailbox = [POSMailbox existingMailboxWithDigipostAddress:self.selectedMailboxDigipostAddress inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        return [NSPredicate predicateWithFormat:@"mailbox == %@", mailbox];
    } else {
        return nil;
    }
}

- (void)reloadFetchedResultsController
{
    self.fetchedResultsController = nil;
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
    _fetchedResultsController.delegate = self;

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
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeUpdate:
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{

    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
