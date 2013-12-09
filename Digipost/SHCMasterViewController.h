//
//  SHCMasterViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHCDetailViewController;

@interface SHCMasterViewController : UITableViewController

@property (strong, nonatomic) SHCDetailViewController *detailViewController;

@end
