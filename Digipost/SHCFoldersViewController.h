//
//  SHCFoldersViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHCBaseTableViewController.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
extern NSString *const kFoldersViewControllerIdentifier;

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPushFoldersIdentifier;

@interface SHCFoldersViewController : SHCBaseTableViewController

- (void)updateFolders;

@end
