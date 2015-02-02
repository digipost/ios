//
//  POSReceiptsTableViewDataSource.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSReceiptsTableViewDataSource.h"
#import "POSModelManager.h"
#import "POSReceiptTableViewCell.h"
#import "POSReceipt.h"
#import "POSDocument.h"
@import CoreData;

@interface POSReceiptsTableViewDataSource ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation POSReceiptsTableViewDataSource

- (instancetype)initAsDataSourceForTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        tableView.dataSource = self;
        _fetchedResultsController.delegate = self;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POSReceiptTableViewCell *receiptTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ReceiptCellIdentifier"
                                                                                    forIndexPath:indexPath];
    [self configureCell:receiptTableViewCell indexPath:indexPath];
    return receiptTableViewCell;
}

- (void)configureCell:(POSReceiptTableViewCell *)receiptTableViewCell indexPath:(NSIndexPath *)indexPath
{
    POSReceipt *receipt = [self.fetchedResultsController objectAtIndexPath:indexPath];
    receiptTableViewCell.storeNameLabel.text = receipt.storeName;
    receiptTableViewCell.amountLabel.text = [NSString stringWithFormat:@"%@", [POSReceipt stringForReceiptAmount:receipt.amount]];
    receiptTableViewCell.amountLabel.accessibilityLabel = [self.numberFormatter stringFromNumber:@(receipt.amount.doubleValue / 100)];
    receiptTableViewCell.amountLabel.accessibilityHint = [self.numberFormatter stringFromNumber:@(receipt.amount.doubleValue / 100)];
    receiptTableViewCell.dateLabel.text = [POSDocument stringForDocumentDate:receipt.timeOfPurchase];
}

- (NSNumberFormatter *)numberFormatter
{
    if (_numberFormatter == nil) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setCurrencyCode:@"NOK"];
        _numberFormatter.alwaysShowsDecimalSeparator = NO;
        _numberFormatter.perMillSymbol = @" ";
        _numberFormatter.decimalSeparator = @" ";
        _numberFormatter.groupingSize = 10;
        [_numberFormatter setCurrencySymbol:@"kroner"];
        [_numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"nb_NO"]];
    }
    return _numberFormatter;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)resetFetchedResultsController
{
    self.fetchedResultsController = nil;
}

- (POSReceipt *)receiptAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:kReceiptEntityName
                                              inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    [fetchRequest setEntity:entity];

    // Order the events by creation date, most recent first.
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeOfPurchase"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:@[ nameDescriptor ]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"franchiseName like %@", self.storeName];
    fetchRequest.predicate = predicate;

    NSError *error;

    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[POSModelManager sharedManager].managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    [_fetchedResultsController performFetch:&error];

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
            [self configureCell:(POSReceiptTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] indexPath:indexPath];
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
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{

    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}
@end
