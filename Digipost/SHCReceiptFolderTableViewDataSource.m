//
//  SHCReceiptFolderTableViewDataSource.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCReceiptFolderTableViewDataSource.h"
#import "POSReceiptFolderTableViewCell.h"
#import "POSReceipt.h"
#import "POSModelManager.h"

@import CoreData;
@interface SHCReceiptFolderTableViewDataSource ()

@property (nonatomic, strong) NSMutableDictionary *receiptGroups;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SHCReceiptFolderTableViewDataSource
#pragma mark - UITableViewDataSource

- (void)refreshContent
{
    self.receiptGroups = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] receiptEntity];

    NSArray *objects = [[POSModelManager sharedManager].managedObjectContext executeFetchRequest:fetchRequest
                                                                                           error:nil];
    NSMutableDictionary *mutableReceipts = [NSMutableDictionary dictionary];

    for (POSReceipt *receipt in objects) {
        if (mutableReceipts[receipt.franchiseName] == nil) {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:receipt];
            mutableReceipts[receipt.franchiseName] = array;
        } else {
            NSMutableArray *array = mutableReceipts[receipt.franchiseName];
            [array addObject:receipt];
        }
    }
    self.receiptGroups = mutableReceipts;
}

- (NSInteger)numberOfReceiptGroups
{
    return [self.receiptGroups count];
}

- (NSString *)storeNameAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sortedKeys = [self.receiptGroups keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        POSReceipt *receipt1 = obj1[0];
        POSReceipt *receipt2 = obj2[0];
        return [receipt1.franchiseName compare:receipt2.franchiseName];
    }];

    return sortedKeys[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.receiptGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sortedKeys = [self.receiptGroups keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        POSReceipt *receipt1 = obj1[0];
        POSReceipt *receipt2 = obj2[0];
        return [receipt1.franchiseName compare:receipt2.franchiseName];
    }];
    NSString *storeName = sortedKeys[indexPath.row];
    NSArray *receipts = self.receiptGroups[storeName];
    POSReceiptFolderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"receiptFolderCell"
                                                                          forIndexPath:indexPath];
    cell.franchiseNameLabel.text = storeName;
    cell.numberOfReceiptsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"RECEIPTS_FOLDER_NUMBER_OF_RECEIPTS_LABEL", @"%i kvitteringer"), [receipts count]];

    return cell;
}

@end
