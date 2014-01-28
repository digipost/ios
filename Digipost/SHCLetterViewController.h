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
extern NSString *const kPushReceiptIdentifier;

@class SHCDocumentsViewController;
@class SHCReceiptsViewController;
@class SHCAttachment;
@class SHCReceipt;

@interface SHCLetterViewController : GAITrackedViewController

@property (weak, nonatomic) SHCDocumentsViewController *documentsViewController;
@property (weak, nonatomic) SHCReceiptsViewController *receiptsViewController;
@property (strong, nonatomic) SHCAttachment *attachment;
@property (strong, nonatomic) SHCReceipt *receipt;

- (void)updateLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem forViewController:(UIViewController *)viewController;

@end
