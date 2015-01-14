//
//  AccountTableViewDataSource.swift
//  Digipost
//
//  Created by Henrik Holmsen on 14.01.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class AccountTableViewDataSource: NSObject,UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let fetchedResultsController: NSFetchedResultsController
    let tableView:UITableView
    
    // MARK: - Class initialiser
    
    init(asDataSourceForTableView tableView: UITableView){
        super.init()
        self.tableView = tableView
        tableView.dataSource = self
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    }
    
    
    
    
//    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//    {
//    return [[self.fetchedResultsController sections] count];
//    }
//    
//    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//    {
//    
//    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
//    }
//    
//    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//    {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mailboxCell"
//    forIndexPath:indexPath];
//    [self configureCell:cell
//    atIndexPath:indexPath];
//    
//    return cell;
//    }
//    
//    // Customize the appearance of table view cells.
//    - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
//    {
//    
//    // Configure the cell with objects from your store
//    POSMailbox *mailbox = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    cell.textLabel.text = mailbox.name;
//    }
//    
//    // convenience method for fetching objects at index path from the database
//    - (id)managedObjectAtIndexPath:(NSIndexPath *)indexPath
//    {
//    id managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    return managedObject;
//    }
//    
//    - (NSFetchedResultsController *)fetchedResultsController
//    {
//    if (_fetchedResultsController != nil) {
//    return _fetchedResultsController;
//    }
//    
//    // Create and configure a fetch request with the Book entity.
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSManagedObjectContext *managedObjectContext = [POSModelManager sharedManager].managedObjectContext;
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mailbox"
//    inManagedObjectContext:managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // Order the events by creation date, most recent first.
//    NSSortDescriptor *ownerDescriptor = [[NSSortDescriptor alloc] initWithKey:@"owner"
//    ascending:YES];
//    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
//    ascending:YES];
//    [fetchRequest setSortDescriptors:@[ ownerDescriptor, nameDescriptor ]];
//    
//    // Create and initialize the fetch results controller.
//    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//    managedObjectContext:managedObjectContext
//    sectionNameKeyPath:nil
//    cacheName:nil];
//    NSError *error;
//    [_fetchedResultsController performFetch:&error];
//    
//    if (error) {
//    NSLog(@"%@", error);
//    }
//    
//    return _fetchedResultsController;
//    }
//    
//    #pragma mark NSFetchedResultsControllerDelegate
//    - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//    {
//    
//    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
//    [self.tableView beginUpdates];
//    }
//    
//    - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//    {
//    
//    UITableView *tableView = self.tableView;
//    
//    switch (type) {
//    
//    case NSFetchedResultsChangeInsert:
//    [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
//    withRowAnimation:UITableViewRowAnimationFade];
//    break;
//    
//    case NSFetchedResultsChangeDelete:
//    [tableView deleteRowsAtIndexPaths:@[ indexPath ]
//    withRowAnimation:UITableViewRowAnimationFade];
//    break;
//    
//    case NSFetchedResultsChangeUpdate:
//    [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
//    atIndexPath:indexPath];
//    break;
//    
//    case NSFetchedResultsChangeMove:
//    [tableView deleteRowsAtIndexPaths:@[ indexPath ]
//    withRowAnimation:UITableViewRowAnimationFade];
//    [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
//    withRowAnimation:UITableViewRowAnimationFade];
//    break;
//    }
//    }
//    
//    - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//    {
//    switch (type) {
//    
//    case NSFetchedResultsChangeInsert:
//    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//    withRowAnimation:UITableViewRowAnimationAutomatic];
//    break;
//    
//    case NSFetchedResultsChangeDelete:
//    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//    withRowAnimation:UITableViewRowAnimationAutomatic];
//    break;
//    
//    case NSFetchedResultsChangeMove:
//    break;
//    
//    case NSFetchedResultsChangeUpdate:
//    break;
//    }
//    }
//    
//    - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//    {
//    
//    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
//    [self.tableView endUpdates];
//    }

}
