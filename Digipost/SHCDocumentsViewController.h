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
extern NSString *const kRefreshDocumentsContentNotificationName;
extern NSString *const kDocumentsViewEditingStatusChangedNotificationName;
extern NSString *const kEditingStatusKey;

@interface SHCDocumentsViewController : SHCBaseTableViewController

@property (copy, nonatomic) NSString *folderName;
@property (copy, nonatomic) NSString *folderDisplayName;
@property (copy, nonatomic) NSString *folderUri;

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *) userDidInititateRequest;

@end
