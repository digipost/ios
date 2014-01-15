//
//  SHCLetterViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GAITrackedViewController.h>

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPushLetterIdentifier;

@class SHCDocumentsViewController;
@class SHCAttachment;

@interface SHCLetterViewController : GAITrackedViewController

@property (weak, nonatomic) SHCDocumentsViewController *documentsViewController;
@property (strong, nonatomic) SHCAttachment *attachment;

@end
