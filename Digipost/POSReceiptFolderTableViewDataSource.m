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

#import "POSReceiptFolderTableViewDataSource.h"
#import "POSReceiptFolderTableViewCell.h"
#import "POSReceipt.h"
#import "POSModelManager.h"

@import CoreData;
@interface POSReceiptFolderTableViewDataSource ()

@property (nonatomic, strong) NSMutableDictionary *receiptGroups;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation POSReceiptFolderTableViewDataSource
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
