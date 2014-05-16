//
//  POSReceiptsTableViewDataSource.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSReceiptsTableViewDataSource.h"
#import "SHCModelManager.h"
#import "SHCReceiptTableViewCell.h"
#import "SHCReceipt.h"
#import "SHCDocument.h"
@import CoreData;

@interface POSReceiptsTableViewDataSource ()
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@end


@implementation POSReceiptsTableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCReceiptTableViewCell *receiptTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ReceiptCellIdentifier" forIndexPath:indexPath];
    SHCReceipt *receipt = [self.fetchedResultsController objectAtIndexPath:indexPath];
    receiptTableViewCell.storeNameLabel.text = receipt.storeName;
    receiptTableViewCell.amountLabel.text = [NSString stringWithFormat:@"%@",[SHCReceipt stringForReceiptAmount:receipt.amount]];
    receiptTableViewCell.dateLabel.text = [SHCDocument stringForDocumentDate:receipt.timeOfPurchase];
    return receiptTableViewCell;
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

- (void)resetFetchedResultsController
{
    self.fetchedResultsController = nil;
}

- (SHCReceipt *)receiptAtIndexPath:(NSIndexPath* )indexPath
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
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kReceiptEntityName inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
    [fetchRequest setEntity:entity];

	// Order the events by creation date, most recent first.
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"storeName" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"franchiseName like %@",self.storeName];
    fetchRequest.predicate = predicate;
    
    NSError *error;
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[SHCModelManager sharedManager].managedObjectContext sectionNameKeyPath:nil cacheName:@"cache"];
    [_fetchedResultsController performFetch:&error];
    
    return _fetchedResultsController;
}
@end
