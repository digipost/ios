//
//  SHCReceiptsViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 20.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHCBaseTableViewController.h"

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPushReceiptsIdentifier;

@interface SHCReceiptsViewController : SHCBaseTableViewController

@property (copy, nonatomic) NSString *mailboxDigipostAddress;
@property (copy, nonatomic) NSString *receiptsUri;

@end
