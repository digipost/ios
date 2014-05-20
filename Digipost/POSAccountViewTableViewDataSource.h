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
- (id)initAsDelegateForTableView:(UITableView *)tableView;

@end
