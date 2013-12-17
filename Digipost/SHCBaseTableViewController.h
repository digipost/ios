//
//  SHCBaseTableViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SHCBaseTableViewController : UITableViewController

@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSEntityDescription *baseEntity;
@property (copy, nonatomic) NSString *sortDescriptorKeyPath;
@property (copy, nonatomic) NSString *screenName;

// Override this method in subclass
- (void)updateContentsFromServer;

- (void)updateFetchedResultsController;
- (void)programmaticallyEndRefresh;

@end
