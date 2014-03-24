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

@class SHCDocumentsViewController;
@class SHCReceiptsViewController;
@class SHCAttachment;
@class SHCReceipt;

@interface SHCLetterViewController : GAITrackedViewController <UISplitViewControllerDelegate>

@property (weak, nonatomic) SHCDocumentsViewController *documentsViewController;
@property (weak, nonatomic) SHCReceiptsViewController *receiptsViewController;
@property (strong, nonatomic) SHCAttachment *attachment;
@property (strong, nonatomic) SHCReceipt *receipt;
@property (strong, nonatomic) UIPopoverController *masterViewControllerPopoverController;

- (void)updateLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem forViewController:(UIViewController *)viewController;
- (void)reloadFromMetadata;

// reloads current open document without dimsissing popover on ipad portrait
- (void)setAttachmentDoNotDismissPopover:(SHCAttachment *)attachment;
- (void)setReceiptDoNotDismissPopover:(SHCReceipt *)receipt;
@end
