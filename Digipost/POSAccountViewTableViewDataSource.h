//
//  POSAccountViewTableViewDataSource.h
//  Digipost
//
//  Created by Håkon Bogen on 19.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface POSAccountViewTableViewDataSource : NSObject<UITableViewDataSource, NSFetchedResultsControllerDelegate>

// designated initalizer
- (id)initAsDataSourceForTableView:(UITableView *)tableView;

// convenience method for fetching objects at index path from the database
- (id)managedObjectAtIndexPath:(NSIndexPath *) indexPath;

@end
