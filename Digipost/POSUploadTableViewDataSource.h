//
//  POSUploadTableViewDataSource.h
//  Digipost
//
//  Created by Håkon Bogen on 09.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Digipost-Swift.h>

@class POSMailbox;

@interface POSUploadTableViewDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

// designated initalizer
- (id)initAsDataSourceForTableView:(UITableView *)tableView;
- (id)managedObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadFetchedResultsController;
@property (nonatomic, strong) NSString *entityDescription;
@property (nonatomic, strong) NSString *selectedMailboxDigipostAddress;

@end
