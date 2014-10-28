//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>
#import <GAITrackedViewController.h>

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPushLetterIdentifier;
extern NSString *const kPushReceiptIdentifier;

@class POSDocumentsViewController;
@class POSReceiptFoldersTableViewController;
@class POSAttachment;
@class POSReceipt;

@interface POSLetterViewController : GAITrackedViewController <UISplitViewControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) POSDocumentsViewController *documentsViewController;
@property (weak, nonatomic) POSReceiptFoldersTableViewController *receiptsViewController;
@property (strong, nonatomic) POSAttachment *attachment;
@property (strong, nonatomic) POSReceipt *receipt;
@property (strong, nonatomic) UIPopoverController *masterViewControllerPopoverController;
@property (assign, nonatomic, getter=isSendingInvoice) BOOL sendingInvoice;

- (void)updateLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem forViewController:(UIViewController *)viewController;
- (void)reloadFromMetadata;

- (void)showMoveDocumentActionSheet;
- (void)showDeleteDocumentActionSheet;
- (void)showOpenInController;

// reloads current open document without dimsissing popover on ipad portrait
- (void)setAttachmentDoNotDismissPopover:(POSAttachment *)attachment;
- (void)setReceiptDoNotDismissPopover:(POSReceipt *)receipt;
@end
