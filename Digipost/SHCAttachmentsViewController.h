//
//  SHCAttachmentsViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPushAttachmentsIdentifier;

@interface SHCAttachmentsViewController : UITableViewController

@property (strong, nonatomic) NSOrderedSet *attachments;

@end
