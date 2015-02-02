//
//  POSReceiptsTableViewDataSource.h
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSReceipt.h"
#import <Foundation/Foundation.h>

@interface POSReceiptsTableViewDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

- (void)resetFetchedResultsController;
- (instancetype)initAsDataSourceForTableView:(UITableView*) tableView;
- (POSReceipt *)receiptAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSString *storeName;

@end
