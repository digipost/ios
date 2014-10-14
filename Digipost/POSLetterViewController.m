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

#import <UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import "POSLetterViewController.h"
#import "POSAttachment.h"
#import "POSDocument.h"
#import <AHKActionSheet.h>
#import "POSFolder+Methods.h"
#import "POSFileManager.h"
#import "POSAPIManager.h"
#import "POSFolderIcon.h"
#import "UIColor+Convenience.h"
#import "UIViewController+BackButton.h"
#import "AHKActionSheet+Convenience.h"
#import "NSString+SHA1String.h"
#import "NSError+ExtraInfo.h"
#import "SHCBaseTableViewController.h"
#import "UIViewController+NeedsReload.h"
#import "Digipost-Swift.h"
#import "POSDocumentsViewController.h"
#import "POSReceiptFoldersTableViewController.h"
#import "POSInvoice.h"
#import "POSMailbox.h"
#import "POSRootResource.h"
#import "POSModelManager.h"
#import "POSReceipt.h"
#import "POSFoldersViewController.h"
#import "SHCAttachmentsViewController.h"
#import "POSDocumentsViewController.h"
#import "UILabel+Digipost.h"
#import "UIView+AutoLayout.h"
#import "POSLetterPopoverTableViewDataSourceAndDelegate.h"
#import "POSLetterPopoverTableViewMobelObject.h"
#import "UIBarButtonItem+DigipostBarButtonItems.h"
static void *kSHCLetterViewControllerKVOContext = &kSHCLetterViewControllerKVOContext;

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushLetterIdentifier = @"PushLetter";

// Google Analytics screen name
NSString *const kLetterViewControllerScreenName = @"Letter";

@interface POSLetterViewController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *moveBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *emptyLetterViewImageView;
@property (strong, nonatomic) UIBarButtonItem *infoBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *actionBarButtonItem;
@property (strong, nonatomic) NSProgress *progress;
@property (strong, nonatomic) UIDocumentInteractionController *openInController;
@property (strong, nonatomic) UIBarButtonItem *invoiceBarButtonItem;
@property (assign, nonatomic, getter=isSendingInvoice) BOOL sendingInvoice;
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView *popoverView;
@property (weak, nonatomic) IBOutlet UITableView *popoverTableView;
@property (weak, nonatomic) IBOutlet UILabel *popoverTitleLabel;
@property (nonatomic, strong) POSLetterPopoverTableViewDataSourceAndDelegate *popoverTableViewDataSourceAndDelegate;
- (IBAction)didTapClosePopoverButton:(id)sender;
@end

@implementation POSLetterViewController

@synthesize attachment = _attachment;
@synthesize receipt = _receipt;

#pragma mark - NSObject

- (void)dealloc
{
    @try {
        [self.progress removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                              context:kSHCLetterViewControllerKVOContext];
    }
    @catch (NSException *exception)
    {
        DDLogDebug(@"Caught an exception: %@", exception);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDocumentsViewEditingStatusChangedNotificationName
                                                  object:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.attachment.fileType isEqualToString:@"html"]) {
        self.webView.backgroundColor = [UIColor whiteColor];
    }
    [self.navigationController.toolbar setBarTintColor:[UIColor colorWithRed:64.0 / 255.0
                                                                       green:66.0 / 255.0
                                                                        blue:69.0 / 255.0
                                                                       alpha:0.95]];
    self.infoBarButtonItem = [UIBarButtonItem barButtonItemWithInfoImageForTarget:self
                                                                           action:@selector(didTapInfo:)];

    self.actionBarButtonItem = [UIBarButtonItem barButtonItemWithActionImageForTarget:self
                                                                               action:@selector(didTapAction:)];

    self.screenName = kLetterViewControllerScreenName;

    self.moveBarButtonItem.title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_MOVE_BUTTON_TITLE", @"Move");
    self.deleteBarButtonItem.title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_DELETE_BUTTON_TITLE", @"Delete");

    [self addTapGestureRecognizersToWebView:self.webView];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeEditingStatus:)
                                                     name:kDocumentsViewEditingStatusChangedNotificationName
                                                   object:nil];
    }
    [self updateLeftBarButtonItem:self.navigationItem.leftBarButtonItem
                forViewController:self];
    [self reloadFromMetadata];
    [self pos_setDefaultBackButton];
    UIBarButtonItem *leftBarButtonItem = self.leftBarButtonItem;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) == NO) {
            if (!leftBarButtonItem) {
                leftBarButtonItem = self.navigationItem.leftBarButtonItem;
            }
            [leftBarButtonItem setImage:[UIImage imageNamed:@"icon-navbar-drawer"]];

            leftBarButtonItem.title = @" ";
            [self.navigationItem setLeftBarButtonItem:leftBarButtonItem
                                             animated:YES];
            [leftBarButtonItem setAction:@selector(showSideMenu:)];
            [leftBarButtonItem setTarget:self];
        } else {
            [self.navigationItem setLeftBarButtonItem:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    BOOL toolbarHidden = NO;

    [self.navigationController setToolbarHidden:toolbarHidden
                                       animated:NO];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    [self updateNavbar];
}

- (void)didChangeEditingStatus:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *isEditing = userInfo[kEditingStatusKey];
    [self.navigationController setToolbarHidden:[isEditing boolValue]
                                       animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unloadContent];

    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // Assuming self.webView is our UIWebView
    // We go though all sub views of the UIWebView and set their backgroundColor to white
    UIView *v = self.webView;
    while (v) {
        if (self.attachment) {
            if ([self.attachment.fileType isEqualToString:@"html"]) {
                self.webView.backgroundColor = [UIColor whiteColor];
            } else {
                v.backgroundColor = RGB(236, 238, 241);
            }
        } else {
            v.backgroundColor = RGB(236, 238, 241);
        }
        v = [v.subviews firstObject];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.progressView.alpha = 0.0;
    self.webView.alpha = 1.0;
    [self updateNavbar];
    if ([self.attachment.fileType isEqualToString:@"html"]) {
        self.webView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogError(@"%@", [error localizedDescription]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL absoluteString] isEqualToString:@"about:blank"]) {
        return YES;
    } else if ([request.URL isFileURL]) {
        return YES;
    } else {
        [UIActionSheet showInView:self.webView
                         withTitle:[request.URL host]
                 cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
            destructiveButtonTitle:nil
                 otherButtonTitles:@[ NSLocalizedString(@"GENERIC_OPEN_IN_SAFARI_BUTTON_TITLE", @"Open in Safari") ]
                          tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if (buttonIndex == 0) {
                                 [[UIApplication sharedApplication] openURL:request.URL];
                             }
                          }];
        return NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    self.openInController = nil;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    self.masterViewControllerPopoverController = popoverController;

    UIViewController *topViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        topViewController = ((UINavigationController *)viewController).topViewController;

        for (UIViewController *vc in((UINavigationController *)viewController).viewControllers) {
            if ([vc isKindOfClass:[POSDocumentsViewController class]]) {
                self.documentsViewController = (id)vc;
            }
        }
    }

    [self updateLeftBarButtonItem:barButtonItem
                forViewController:topViewController];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.masterViewControllerPopoverController = nil;

    [self setInfoViewVisible:NO];

    [self.navigationItem setLeftBarButtonItem:nil
                                     animated:YES];
}
#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSParameterAssert(object);
    NSParameterAssert(keyPath);
    NSParameterAssert(change);
    if (context == kSHCLetterViewControllerKVOContext && object == self.progress && [keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
        NSProgress *progress = (NSProgress *)object;

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:progress.fractionCompleted animated:YES];
        });
    } else if ([super respondsToSelector:@selector(observeValueForKeyPath:
                                                                 ofObject:
                                                                   change:
                                                                  context:)]) {

        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - Properties

- (POSAttachment *)attachment
{
    return _attachment;
}

- (void)setAttachment:(POSAttachment *)attachment
{
    self.errorLabel.alpha = 0;
    BOOL new = attachment != _attachment;

    _attachment = attachment;
    _receipt = nil;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (self.masterViewControllerPopoverController) {
            [self.masterViewControllerPopoverController dismissPopoverAnimated:YES];
        }

        [self showEmptyView:new];
        if (new) {
            self.errorLabel.alpha = 0;
        }
        [self reloadFromMetadata];
        // update the read status for ipad view
    }
}

- (void)setAttachmentDoNotDismissPopover:(POSAttachment *)attachment
{
    self.errorLabel.alpha = 0;
    BOOL new = attachment != _attachment;

    _attachment = attachment;
    _receipt = nil;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        [self showEmptyView:new];
        [self reloadFromMetadata];
        // update the read status for ipad view
    }
}

- (POSReceipt *)receipt
{
    return _receipt;
}

- (void)setReceipt:(POSReceipt *)receipt
{
    BOOL new = receipt != _receipt;

    _receipt = receipt;
    _attachment = nil;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (self.masterViewControllerPopoverController) {
            [self.masterViewControllerPopoverController dismissPopoverAnimated:YES];
        }

        [self showEmptyView:new];
        [self reloadFromMetadata];
    }
}

- (void)setReceiptDoNotDismissPopover:(POSReceipt *)receipt
{
    BOOL new = receipt != _receipt;

    _receipt = receipt;
    _attachment = nil;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        [self showEmptyView:new];
        [self reloadFromMetadata];
        // update the read status for ipad view
    }
}

#pragma mark - IBActions

- (IBAction)didTapMove:(UIBarButtonItem *)sender
{
    [self showBlurredActionSheetWithFolders];
}

- (void)showBlurredActionSheetWithFolders
{

    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"Velg mappe"];
    [actionSheet setupStyle];
    POSDocumentsViewController *documentsViewController;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        for (UIViewController *viewController in self.splitViewController.viewControllers) {
            if ([viewController isKindOfClass:[UINavigationController class]]) {
                for (UIViewController *subViewController in((UINavigationController *)viewController).viewControllers) {
                    if ([subViewController isKindOfClass:[POSDocumentsViewController class]]) {
                        documentsViewController = (id)subViewController;
                        break;
                    }
                }
            }
        }
    } else {
        documentsViewController = self.documentsViewController;
    }

    NSArray *folders = [POSFolder foldersForUserWithMailboxDigipostAddress:documentsViewController.mailboxDigipostAddress
                                                    inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];

    for (POSFolder *folder in folders) {

        UIImage *image = [POSFolderIcon folderIconWithName:folder.iconName].smallImage;

        image = [image scaleToSize:CGSizeMake(18, 18)];

        if (image == nil) {
            image = [UIImage imageNamed:@"list-icon-inbox"];
        }
        if ([documentsViewController.folderName isEqualToString:folder.name] == NO) {
            [actionSheet addButtonWithTitle:folder.displayName
                                      image:image
                                       type:AHKActionSheetButtonTypeDefault
                                    handler:^(AHKActionSheet *actionSheet, id item) {
                                        if (item) {
                                            [self moveDocument:self.attachment.document toFolder:folder];
                                        }
                                    }];
        }
    }

    [actionSheet show];
}

- (void)moveDocument:(POSDocument *)document toFolder:(POSFolder *)folder
{
    [[POSAPIManager sharedManager] moveDocument:document
        toFolder:folder
        withSuccess:^{
                                        document.folder = folder;
                                        
                                        [[POSModelManager sharedManager].managedObjectContext save:nil];
            
                                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                            if ([self.attachment.document isEqual:document]){
                                                self.attachment = nil;
                                            }
                                             [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
                                        }else {
                                            [self.navigationController popToViewController:self.documentsViewController animated:YES];
                                        }
        }
        failure:^(NSError *error) {
                                            
                                            NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                    // We were unauthorized, due to the session being invalid.
                                                    // Let's retry in the next run loop
                                                    double delayInSeconds = 0.0;
                                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                        [self moveDocument:document toFolder:folder];
                                                    });
                                                    
                                                    return;
                                                }
                                            }
                                            
                                            
                                            [UIAlertView showWithTitle:error.errorTitle
                                                               message:[error localizedDescription]
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@[error.okButtonTitle]
                                                              tapBlock:error.tapBlock];
        }];
}
- (IBAction)didTapDelete:(UIBarButtonItem *)sender
{
    NSString *title = nil;
    if ([self.attachment.document.attachments count] > 1) {
        title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_DELETE_WARNING_TITLE", @"Delete warning");
    }

    [UIActionSheet showFromBarButtonItem:sender
                                animated:YES
                               withTitle:title
                       cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
                  destructiveButtonTitle:NSLocalizedString(@"GENERIC_DELETE_BUTTON_TITLE", @"Delete")
                       otherButtonTitles:nil
                                tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                    if (buttonIndex == 0) {
                                        if (self.attachment) {
                                            [self deleteDocument];
                                        } else if (self.receipt) {
                                            [self deleteReceipt];
                                        }
                                    }
                                }];
}

- (IBAction)dismissInfo:(UIGestureRecognizer *)gestureRecognizer
{
    [self setInfoViewVisible:NO];
}

#pragma mark - Private methods

- (void)loadContent
{

    POSBaseEncryptedModel *baseEncryptionModel = nil;

    if (self.attachment) {
        baseEncryptionModel = self.attachment;

    } else if (self.receipt) {
        baseEncryptionModel = self.receipt;
    }

    NSString *encryptedFilePath = [baseEncryptionModel encryptedFilePath];
    NSString *decryptedFilePath = [baseEncryptionModel decryptedFilePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        NSError *error = nil;
        if (![[POSFileManager sharedFileManager] decryptDataForBaseEncryptionModel:baseEncryptionModel
                                                                             error:&error]) {
            [self loadContentFromWebWithBaseEncryptionModel:baseEncryptionModel];
            return;
        }

        NSURL *fileURL = [NSURL fileURLWithPath:decryptedFilePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [self.webView loadRequest:request];

        [self updateToolbarItemsWithInvoice:(self.attachment.invoice != nil)];
        [self updateNavbar];
    } else {
        [self loadContentFromWebWithBaseEncryptionModel:baseEncryptionModel];
    }
}

- (void)loadContentFromWebWithBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel
{
    NSParameterAssert(baseEncryptionModel);
    NSProgress *progress = nil;
    self.progressView.progress = 0.0;

    if ([baseEncryptionModel isKindOfClass:[POSAttachment class]]) {
        [UIView animateWithDuration:0.3
                              delay:0.6
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.progressView.alpha = 1.0;
                         }
                         completion:nil];

        progress = [[NSProgress alloc] initWithParent:nil
                                             userInfo:nil];
        NSInteger fileSize = [self.attachment.fileSize integerValue];
        progress.totalUnitCount = (int64_t)fileSize;

        if ([self.progress respondsToSelector:@selector(removeObserver:forKeyPath:context:)]) {
            [self.progress removeObserver:self
                               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                                  context:kSHCLetterViewControllerKVOContext];
        }
        [progress addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                      options:NSKeyValueObservingOptionNew
                      context:kSHCLetterViewControllerKVOContext];

        self.progress = progress;
    }
    [[POSAPIManager sharedManager] cancelDownloadingBaseEncryptionModels];
    NSString *baseEncryptionModelUri = baseEncryptionModel.uri;
    if (baseEncryptionModelUri == nil && self.attachment.openingReceiptUri != nil) {
        POSAttachment *attachment = (id)baseEncryptionModel;

        __block POSDocument *document = attachment.document;
        NSString *subject = attachment.subject;

        NSString *updateURI = document.updateUri;
        [[POSAPIManager sharedManager] updateDocument:attachment.document
            success:^{
                // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
                __block POSBaseEncryptedModel *changedBaseEncryptionModel = self.attachment;
                document = [POSDocument existingDocumentWithUpdateUri:updateURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                [document.attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    POSAttachment *attachment = (id)obj;
                    if ([attachment.subject isEqualToString:subject]){
                        changedBaseEncryptionModel = attachment;
                    }
                }];
                
                [[POSAPIManager sharedManager] downloadBaseEncryptionModel:changedBaseEncryptionModel
                                                              withProgress:progress
                                                                   success:^{
                NSError *error = nil;
                if (![[POSFileManager sharedFileManager] encryptDataForBaseEncryptionModel:changedBaseEncryptionModel error:&error]) {
                    [UIAlertView showWithTitle:error.errorTitle
                                       message:[error localizedDescription]
                             cancelButtonTitle:nil
                             otherButtonTitles:@[error.okButtonTitle]
                                      tapBlock:error.tapBlock];
                }
                if ([self.attachment.fileType isEqualToString:@"html"]){
                    self.view.backgroundColor = [UIColor whiteColor];
                }
                
                                                                       
                NSURL *fileURL = [NSURL fileURLWithPath:[changedBaseEncryptionModel decryptedFilePath]];
                NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
                [self.webView loadRequest:request];
                
                [self updateToolbarItemsWithInvoice:(self.attachment.invoice != nil)];
                
                if ([_attachment.read boolValue] == NO ) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
                
                }
                [self updateNavbar];
                                                                   }
                                                                   failure:^(NSError *error) {
                                                                       
                                                                   }];
            }
            failure:^(NSError *error) {}];
    } else {

        [[POSAPIManager sharedManager] downloadBaseEncryptionModel:baseEncryptionModel
            withProgress:progress
            success:^{
                
                                                           // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
                                                           POSBaseEncryptedModel *changedBaseEncryptionModel = nil;
                                                           if (self.attachment) {
                                                               changedBaseEncryptionModel = [POSAttachment existingAttachmentWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                                                           } else {
                                                               changedBaseEncryptionModel = [POSReceipt existingReceiptWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                                                           }
                                                           
                                                           NSError *error = nil;
                                                           if (![[POSFileManager sharedFileManager] encryptDataForBaseEncryptionModel:changedBaseEncryptionModel error:&error]) {
                                                               [UIAlertView showWithTitle:error.errorTitle
                                                                                  message:[error localizedDescription]
                                                                        cancelButtonTitle:nil
                                                                        otherButtonTitles:@[error.okButtonTitle]
                                                                                 tapBlock:error.tapBlock];
                                                           }
                                                           
                                                           NSURL *fileURL = [NSURL fileURLWithPath:[changedBaseEncryptionModel decryptedFilePath]];
                if ([self.attachment.fileType isEqualToString:@"html"]){
                    self.webView.backgroundColor = [UIColor whiteColor];
                }
                                                           NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
                                                           [self.webView loadRequest:request];
                                                           
                                                           [self updateToolbarItemsWithInvoice:(self.attachment.invoice != nil)];
                                                           
                                                           if ([_attachment.read boolValue] == NO ) {
                                                               [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
                                                           }
            }
            failure:^(NSError *error) {
                                                           
                                                           BOOL unauthorized = NO;
                                                           
                                                           if ([[error domain] isEqualToString:kAPIManagerErrorDomain] &&
                                                               [error code] == SHCAPIManagerErrorCodeUnauthorized) {
                                                               unauthorized = YES;
                                                           } else {
                                                               NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                                   if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                                       unauthorized = YES;
                                                                   }
                                                               }
                                                           }
                                                           
                                                           if (unauthorized) {
                                                               // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
                                                               POSBaseEncryptedModel *changedBaseEncryptionModel = nil;
                                                               if (self.attachment) {
                                                                   changedBaseEncryptionModel = [POSAttachment existingAttachmentWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                                                               } else {
                                                                   changedBaseEncryptionModel = [POSReceipt existingReceiptWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                                                               }
                                                               
                                                               
                                                               [self updateNavbar];
                                                               // We were unauthorized, due to the session being invalid.
                                                               // Let's retry in the next run loop
                                                               [self performSelector:@selector(loadContentFromWebWithBaseEncryptionModel:) withObject:changedBaseEncryptionModel afterDelay:0.0];
                                                               
                                                               return;
                                                           } else {
                                                               
                                                               [UIAlertView showWithTitle:error.errorTitle
                                                                                  message:[error localizedDescription]
                                                                        cancelButtonTitle:nil
                                                                        otherButtonTitles:@[error.okButtonTitle]
                                                                                 tapBlock:error.tapBlock];
                                                           }
            }];
    }
}

- (void)unloadContent
{
    [[POSAPIManager sharedManager] cancelDownloadingBaseEncryptionModels];
    [[POSFileManager sharedFileManager] removeAllDecryptedFiles];
}

- (BOOL)attachmentHasValidFileType
{
    // Receipts are always pdf's.
    if (self.receipt) {
        return YES;
    }

    // A list of file types that are tried and tested with UIWebView
    NSArray *validFilesTypes = @[ @"pdf", @"png", @"jpg", @"jpeg", @"gif", @"php", @"doc", @"ppt", @"docx", @"xlsx", @"pptx", @"txt", @"html", @"numbers", @"key", @"pages" ];

    return [validFilesTypes containsObject:self.attachment.fileType];
}

- (void)showInvalidFileTypeView
{
    self.errorLabel.text = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVALID_FILE_TYPE_MESSAGE", @"Invalid file type message");
    self.webView.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.errorLabel.alpha = 1.0;
                     }];
}

- (void)didSingleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    // this feature should not be activated if voiceover is running
    if (UIAccessibilityIsVoiceOverRunning()) {
        return;
    }
    BOOL barsHidden = self.navigationController.isToolbarHidden;

    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [self.navigationController setNavigationBarHidden:!barsHidden
                                                 animated:YES];
        [self.navigationController setToolbarHidden:!barsHidden
                                           animated:YES];

        UIStatusBarStyle statusBarStyle = barsHidden ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle
                                                    animated:YES];
    }
}

- (void)didDoubleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
}

- (void)moveDocumentToFolder:(POSFolder *)folder
{
    NSAssert(self.attachment.document != nil, @"no document");

    [[POSAPIManager sharedManager] moveDocument:self.attachment.document
        toFolder:folder
        withSuccess:^{
                                        _attachment = nil;
                                        if (self.documentsViewController) {
                                            self.documentsViewController.needsReload = YES;
                                            
                                            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                                                [self showEmptyView:YES];
                                            } else {
                                                // Becuase we might have been pushed from the attachments vc, make sure that we pop
                                                // all the way back to the documents vc.
                                                [self.navigationController popToViewController:self.documentsViewController animated:YES];
                                            }
                                        }
                                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
                                            [self showEmptyView:YES];
                                            
                                        }
        }
        failure:^(NSError *error) {
                                            
                                            NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                    // We were unauthorized, due to the session being invalid.
                                                    // Let's retry in the next run loop
                                                    [self performSelector:@selector(moveDocumentToFolder:) withObject:folder afterDelay:0.0];
                                                    
                                                    return;
                                                }
                                            }
                                            
                                            [UIAlertView showWithTitle:error.errorTitle
                                                               message:[error localizedDescription]
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@[error.okButtonTitle]
                                                              tapBlock:error.tapBlock];
        }];
}

- (void)deleteDocument
{

    NSAssert(self.attachment != nil, @"no attachment document to delete");
    [[POSAPIManager sharedManager] deleteDocument:self.attachment.document
        withSuccess:^{
                                          _attachment = nil;
                                          if (self.documentsViewController) {
                                              
                                              self.documentsViewController.needsReload = YES;
                                              // Becuase we might have been pushed from the attachments vc, make sure that we pop
                                              // all the way back to the documents vc.
                                              [self.navigationController popToViewController:self.documentsViewController animated:YES];
                                          }
                                          ;
                                          if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
                                              [self showEmptyView:YES];
                                          }
        }
        failure:^(NSError *error) {
                                              
                                              NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                  if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                      // We were unauthorized, due to the session being invalid.
                                                      // Let's retry in the next run loop
                                                      [self performSelector:@selector(deleteDocument) withObject:nil afterDelay:0.0];
                                                      
                                                      return;
                                                  }
                                              }
                                              
                                              [UIAlertView showWithTitle:error.errorTitle
                                                                 message:[error localizedDescription]
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@[error.okButtonTitle]
                                                                tapBlock:error.tapBlock];
        }];
}

- (void)deleteReceipt
{
    [[POSAPIManager sharedManager] deleteReceipt:self.receipt
        withSuccess:^{
                                         
                                         _receipt = nil;
                                         if (self.receiptsViewController) {
                                             self.receiptsViewController.needsReload = YES;
                                             
                                             // Becuase we might have been pushed from the attachments vc, make sure that we pop
                                             // all the way back to the documents vc.
                                             [self.navigationController popToViewController:self.receiptsViewController animated:YES];
                                         }
        }
        failure:^(NSError *error) {
                                             
                                             NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                             if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                 if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                     // We were unauthorized, due to the session being invalid.
                                                     // Let's retry in the next run loop
                                                     [self performSelector:@selector(deleteReceipt) withObject:nil afterDelay:0.0];
                                                     
                                                     return;
                                                 }
                                             }
                                             
                                             [UIAlertView showWithTitle:error.errorTitle
                                                                message:[error localizedDescription]
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@[error.okButtonTitle]
                                                               tapBlock:error.tapBlock];
        }];
}

- (void)didTapInfo:(UIBarButtonItem *)barButtonItem
{
    BOOL shouldBeVisible = (self.shadowView.alpha == 0.0) ? YES : NO;

    [self setInfoViewVisible:shouldBeVisible];
}

- (void)didTapAction:(UIBarButtonItem *)barButtonItem
{
    [self setInfoViewVisible:NO];

    if (self.openInController == nil) {

        POSBaseEncryptedModel *baseEncryptionModel = nil;

        if (self.attachment) {
            baseEncryptionModel = self.attachment;

        } else if (self.receipt) {
            baseEncryptionModel = self.receipt;
        }

        NSString *encryptedFilePath = [baseEncryptionModel encryptedFilePath];
        NSString *decryptedFilePath = [baseEncryptionModel decryptedFilePath];

        NSURL *fileURL = nil;

        if ([[NSFileManager defaultManager] fileExistsAtPath:decryptedFilePath]) {
            fileURL = [NSURL fileURLWithPath:decryptedFilePath];
        } else if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
            NSError *error = nil;
            if (![[POSFileManager sharedFileManager] decryptDataForBaseEncryptionModel:baseEncryptionModel
                                                                                 error:&error]) {
                [UIAlertView showWithTitle:error.errorTitle
                                   message:[error localizedDescription]
                         cancelButtonTitle:nil
                         otherButtonTitles:@[ error.okButtonTitle ]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
                return;
            }

            fileURL = [NSURL fileURLWithPath:decryptedFilePath];
        } else {
            return;
        }

        self.openInController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.openInController.delegate = self;
        [self.openInController presentOpenInMenuFromBarButtonItem:barButtonItem
                                                         animated:YES];
    } else {
        [self.openInController dismissMenuAnimated:YES];
    }
}

- (void)didTapInvoice:(UIBarButtonItem *)barButtonItem
{
    NSString *title = nil;
    NSString *message = nil;
    NSString *actionButtonTitle = nil;
    NSString *cancelButtonTitle = nil;

    if (self.attachment.invoice.timePaid) {
        title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_PAID_TITLE", @"The invoice has been registered");

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;

        NSString *timePaid = [dateFormatter stringFromDate:self.attachment.invoice.timePaid];

        NSString *format = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_PAID_MESSAGE", @"Paid message");
        message = [NSString stringWithFormat:format, timePaid];

        actionButtonTitle = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_GO_TO_BANK_BUTTON_TITLE", @"Go to bank");
        cancelButtonTitle = NSLocalizedString(@"GENERIC_CLOSE_BUTTON_TITLE", @"Close");

    } else if ([self.attachment.invoice.canBePaidByUser boolValue] && [self.attachment.invoice.sendToBankUri length] > 0) {
        title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_SEND_TITLE", @"Send to bank?");

        NSString *bankAccountNumber = self.attachment.document.folder.mailbox.rootResource.currentBankAccount ?: NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_UNKNOWN_BANK_ACCOUNT_NUMBER", @"unknown bank account number");

        NSString *format = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_SEND_MESSAGE", @"Send message");
        message = [NSString stringWithFormat:format, bankAccountNumber];

        actionButtonTitle = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_ACTION_BUTTON_SEND_TITLE", @"Send to bank");
        cancelButtonTitle = NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel");

    } else {
        title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_PAYMENT_TIPS_TITLE", @"Send to bank");
        message = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_PAYMENT_TIPS_MESSAGE", @"Payment tips message");

        actionButtonTitle = NSLocalizedString(@"GENERIC_CLOSE_BUTTON_TITLE", @"Close");
    }

    [UIAlertView showWithTitle:title
                       message:message
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:@[ actionButtonTitle ]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex > 0) {
                              if (self.attachment.invoice.timePaid) {
                                  NSURL *url = [NSURL URLWithString:self.attachment.invoice.bankHomepage];
                                  [[UIApplication sharedApplication] openURL:url];
                              } else if ([self.attachment.invoice.canBePaidByUser boolValue] && [self.attachment.invoice.sendToBankUri length] > 0) {
                                  [self sendInvoiceToBank];
                              }
                          }
                      }];
}

- (void)setInfoViewVisible:(BOOL)visible
{

    if (visible && self.shadowView.alpha == 0.0) {

        if (self.popoverTableViewDataSourceAndDelegate == nil) {
            self.popoverTableViewDataSourceAndDelegate = [[POSLetterPopoverTableViewDataSourceAndDelegate alloc] init];
        }

        NSMutableArray *mutableObjectsInMetadata = [NSMutableArray array];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // Dateformatter for format: 13.02.2013 kl. 09.49 - Digipost format
        [dateFormatter setDateFormat:@"dd.MM.YYYY 'kl.' hh.mm"];

        self.popoverTitleLabel.text = self.attachment.subject;
        if (self.attachment) {
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_TITLE", @"From")
                                                                                        description:self.attachment.document.creatorName]];
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_DATE_TITLE", @"Date")
                                                                                        description:[dateFormatter stringFromDate:self.attachment.document.createdAt]]];
        } else if (self.receipt) {
            self.popoverTitleLabel.text = self.receipt.storeName;
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_DATE_TITLE", @"Date")
                                                                                        description:[dateFormatter stringFromDate:self.receipt.timeOfPurchase]]];
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_AMOUNT", @"Beløp")
                                                                                        description:[NSString stringWithFormat:@"%@", [POSReceipt stringForReceiptAmount:self.receipt.amount]]]];

            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_RECEIPT", @"Kort")
                                                                                        description:[NSString stringWithFormat:@"%@", self.receipt.card]]];
        }

        if (self.attachment.invoice) {

            NSString *invoiceAmount = [POSInvoice stringForInvoiceAmount:self.attachment.invoice.amount];
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_AMOUNT", @"Beløp")
                                                                                        description:invoiceAmount]];

            [dateFormatter setDateFormat:@"dd.MM.YYYY"];
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_DUEDATE", @"Forfallsdato")
                                                                                        description:[dateFormatter stringFromDate:self.attachment.invoice.dueDate]]];
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_TO_ACCOUNT", @"Til konto")
                                                                                        description:self.attachment.invoice.accountNumber]];

            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_KID", @"KID")
                                                                                        description:[NSString stringWithFormat:@"%@", self.attachment.invoice.kid]]];
            NSString *statusDescriptionText = [self.attachment.invoice statusDescriptionText];
            if (statusDescriptionText) {
                [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_STATUS", @"Status")
                                                                                            description:statusDescriptionText]];
            }
        }

        self.popoverTableView.delegate = self.popoverTableViewDataSourceAndDelegate;
        self.popoverTableView.dataSource = self.popoverTableViewDataSourceAndDelegate;
        self.popoverTableViewDataSourceAndDelegate.lineObjects = mutableObjectsInMetadata;

        [UIView animateWithDuration:0.2
                         animations:^{
                             self.shadowView.alpha = 1.0;
                         }];

        [self.navigationController.toolbar setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
        [self.navigationController.toolbar setUserInteractionEnabled:NO];
        [self.popoverTableView reloadData];

    } else if (!visible && self.shadowView.alpha == 1.0) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.shadowView.alpha = 0.0;
                         }];

        [self.navigationController.toolbar setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
        [self.navigationController.toolbar setUserInteractionEnabled:YES];
    }
}

- (void)sendInvoiceToBank
{
    self.sendingInvoice = YES;
    [self updateToolbarItemsWithInvoice:YES];

    [[POSAPIManager sharedManager] sendInvoiceToBank:self.attachment.invoice
        withSuccess:^{
                                             
                                             // Now, we've successfully sent the invoice to the bank, but we still need updated document metadata
                                             // to be able to correctly display the contents of the alertview if the user taps the "sent to bank" button.
            [self updateDocuments];
            [self updateToolbarItemsWithInvoice:YES];
        }
        failure:^(NSError *error) {
                                                 NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                                 if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                     if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                         // We were unauthorized, due to the session being invalid.
                                                         // Let's retry in the next run loop
                                                         [self performSelector:@selector(sendInvoiceToBank) withObject:nil afterDelay:0.0];
                                                         
                                                         return;
                                                     }
                                                 }
                                                 
                                                 self.sendingInvoice = NO;
                                                 [self updateToolbarItemsWithInvoice:YES];
                                                 
                                                 [UIAlertView showWithTitle:error.errorTitle
                                                                    message:[error localizedDescription]
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@[error.okButtonTitle]
                                                                   tapBlock:error.tapBlock];
        }];
}

- (void)updateDocuments
{
    if ([POSAPIManager sharedManager].isUpdatingDocuments) {
        return;
    }

    NSString *attachmentUri = self.attachment.uri;

    [[POSAPIManager sharedManager] updateDocumentsInFolderWithName:self.attachment.document.folder.name
        mailboxDigipostAddress:self.documentsViewController.mailboxDigipostAddress
        folderUri:self.attachment.document.folder.uri
        success:^{
                                                               [self updateAttachmentWithAttachmentUri:attachmentUri];
                                                               self.sendingInvoice = NO;
                                                               [self updateToolbarItemsWithInvoice:YES];
            [self updateNavbar];
        }
        failure:^(NSError *error) {
                                                               
                                                               NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                                   if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                                       // We were unauthorized, due to the session being invalid.
                                                                       // Let's retry in the next run loop
                                                                       [self performSelector:@selector(updateDocuments) withObject:nil afterDelay:0.0];
                                                                       
                                                                       return;
                                                                   }
                                                               }
                                                               
                                                               [UIAlertView showWithTitle:error.errorTitle
                                                                                  message:[error localizedDescription]
                                                                        cancelButtonTitle:nil
                                                                        otherButtonTitles:@[error.okButtonTitle]
                                                                                 tapBlock:error.tapBlock];
        }];
}

- (void)updateAttachmentWithAttachmentUri:(NSString *)uri
{
    self.attachment = [POSAttachment existingAttachmentWithUri:uri
                                        inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
}

- (void)updateToolbarItemsWithInvoice:(BOOL)invoice
{
    UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                target:nil
                                                                                                action:nil];

    NSMutableArray *items = [NSMutableArray array];
    if (invoice) {
        NSString *title = nil;
        if (self.isSendingInvoice) {
            title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_SENDING_TITLE", @"Sending...");
        } else if (self.attachment.invoice.timePaid) {
            title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_PAID_TITLE", @"Sent to bank");
        } else if ([self.attachment.invoice.canBePaidByUser boolValue] && [self.attachment.invoice.sendToBankUri length] > 0) {
            title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_SEND_TITLE", @"Send to bank");
        } else {
            title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_PAYMENT_TIPS_TITLE", @"Payment tips");
        }

        self.invoiceBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(didTapInvoice:)];
        self.invoiceBarButtonItem.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self.invoiceBarButtonItem setEnabled:!self.isSendingInvoice];

        if (self.attachment) {
            [items addObjectsFromArray:@[ self.moveBarButtonItem, flexibleSpaceBarButtonItem ]];
        }
        [items addObjectsFromArray:@[ self.invoiceBarButtonItem ]];
        [items addObjectsFromArray:@[ flexibleSpaceBarButtonItem, self.deleteBarButtonItem ]];

        self.toolbarItems = items;
    } else {
        if (self.attachment) {
            [items addObject:self.moveBarButtonItem];
            [items addObjectsFromArray:@[ flexibleSpaceBarButtonItem, self.deleteBarButtonItem ]];
        } else if (self.receipt) {
            [items addObjectsFromArray:@[ flexibleSpaceBarButtonItem, self.deleteBarButtonItem ]];
        }
        if ([items count] > 0) {
            [self.navigationController setToolbarHidden:NO
                                               animated:YES];
        } else {
            [self.navigationController setToolbarHidden:YES
                                               animated:YES];
        }
        self.toolbarItems = items;
    }
}

- (void)updateLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem forViewController:(UIViewController *)viewController
{
    if (!leftBarButtonItem) {
        leftBarButtonItem = self.navigationItem.leftBarButtonItem;
    }
    [leftBarButtonItem setImage:[UIImage imageNamed:@"icon-navbar-drawer"]];

    leftBarButtonItem.title = @" ";
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem
                                     animated:YES];

    if (self.view.window && self.navigationItem.leftBarButtonItem && self.masterViewControllerPopoverController) {
        [self.masterViewControllerPopoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem
                                                           permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                           animated:YES];
    } else {
        if ([UIApplication sharedApplication].statusBarOrientation != (UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft)) {
            [leftBarButtonItem setAction:@selector(showSideMenu:)];
            [leftBarButtonItem setTarget:self];
        }
    }
}

- (void)showSideMenu:(id)sender
{
    if (self.view.window && self.navigationItem.leftBarButtonItem && self.masterViewControllerPopoverController) {
        [self.masterViewControllerPopoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem
                                                           permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                           animated:YES];
    }
}

- (void)showEmptyView:(BOOL)showEmptyView
{
    if (showEmptyView) {
        self.webView.alpha = 0.0;
    }

    self.emptyLetterViewImageView.hidden = !showEmptyView;
    [self updateToolbarItemsWithInvoice:NO];
}

- (POSBaseEncryptedModel *)currentBaseEncryptModel
{
    if (self.receipt) {
        return self.receipt;
    }
    if (self.attachment) {
        return self.attachment;
    }
    return nil;
}

- (void)updateNavbar
{
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];

    if (self.attachment || self.receipt) {

        if ([self interactionControllerCanShareContent:[self currentBaseEncryptModel]]) {
            [rightBarButtonItems addObjectsFromArray:@[ self.actionBarButtonItem, self.infoBarButtonItem ]];

        } else {
            [rightBarButtonItems addObject:self.infoBarButtonItem];
        }
    }

    self.navigationItem.rightBarButtonItems = [rightBarButtonItems count] > 0 ? rightBarButtonItems : nil;
}

- (void)reloadFromMetadata
{

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        if (!self.attachment && !self.receipt) {
            [self showEmptyView:YES];
            return;
        } else {
            [self showEmptyView:NO];
        }
    }

    if (![self attachmentHasValidFileType]) {
        [self showInvalidFileTypeView];
    }

    [self loadContent];
    [self updateNavbar];
}

- (IBAction)didTapClosePopoverButton:(id)sender
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.shadowView.alpha = 0.0;
                     }];

    [self.navigationController.toolbar setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
    [self.navigationController.toolbar setUserInteractionEnabled:YES];
}
@end
