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

#import "GAI.h"

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPushLetterIdentifier;

@class POSDocumentsViewController;
@class POSAttachment;

@interface POSLetterViewController : GAITrackedViewController <UISplitViewControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) POSDocumentsViewController *documentsViewController;
@property (strong, nonatomic) POSAttachment *attachment;
@property (strong, nonatomic) UIPopoverController *masterViewControllerPopoverController;
@property (assign, nonatomic, getter=isSendingInvoice) BOOL sendingInvoice;

// index of the attachment showing, if its in a document list of multiple attachments
@property (nonatomic) NSInteger indexOfAttachment;

- (void)updateLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem forViewController:(UIViewController *)viewController;
- (void)reloadFromMetadata;

- (void)showMoveDocumentActionSheet;
- (void)showDeleteDocumentActionSheet;
- (void)showOpenInControllerModally;
- (void)showRenameAlertView;

- (void)didTapMoreOptionsBarButtonItem:(id) sender;
- (void)didSingleTapWebView:(id) sender;
- (void)didDoubleTapWebView:(id) sender;
- (void)didTapInvoice:(id) sender;
- (void)didTapInformationBarButtonItem:(id) sender;
- (void)didTapMoveDocumentBarButtonItem:(id) sender;
- (void)didTapDeleteDocumentBarButtonItem:(id) sender;
- (void)didTapRenameDocumentBarButtonItem:(id) sender;
- (void)didTapOpenDocumentInExternalAppBarButtonItem:(id) sender;
- (void)openExternalLink:(NSString*) url;
- (void)setTitle:(NSString *)title;

// reloads current open document without dimsissing popover on ipad portrait
- (void)setAttachmentDoNotDismissPopover:(POSAttachment *)attachment;
@end
