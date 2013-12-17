//
//  SHCDocumentsViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHCBaseTableViewController.h"

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPushDocumentsIdentifier;

@class SHCFolder;

@interface SHCDocumentsViewController : SHCBaseTableViewController

@property (strong, nonatomic) SHCFolder *folder;

@end
