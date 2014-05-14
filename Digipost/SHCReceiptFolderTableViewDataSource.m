//
//  SHCReceiptFolderTableViewDataSource.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCReceiptFolderTableViewDataSource.h"
#import "POSReceiptFolderTableViewCell.h"
#import "SHCReceipt.h"
#import "SHCModelManager.h"

@import CoreData;
@interface SHCReceiptFolderTableViewDataSource()

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong) NSMutableDictionary *receiptGroups;

@end

@implementation SHCReceiptFolderTableViewDataSource
#pragma mark - UITableViewDataSource

- (void)refreshContent
{
    self.receiptGroups = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] receiptEntity];
    
    NSArray *objects = [[SHCModelManager sharedManager].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSMutableDictionary *mutableReceipts = [NSMutableDictionary dictionary];
   
    for (SHCReceipt *receipt  in objects) {
        if (mutableReceipts[receipt.franchiseName] == nil){
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:receipt];
            mutableReceipts[receipt.franchiseName] = array;
        }else {
            NSMutableArray *array = mutableReceipts[receipt.franchiseName];
            [array addObject:receipt];
        }
    }
    self.receiptGroups = mutableReceipts;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
//    if (number == 0) {
//        [self showTableViewBackgroundView:YES];
//    }
    
//    return number;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.receiptGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *storeName = self.receiptGroups.allKeys[indexPath.row];

    POSReceiptFolderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"receiptFolderCell" forIndexPath:indexPath];
    cell.textLabel.text = storeName;
//    cell.dateLabel.text = [SHCDocument stringForDocumentDate:receipt.timeOfPurchase];
    
    return cell;
}

@end
