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
#import "SHCLetterViewController.h"
#import "SHCAttachment.h"
#import "SHCDocument.h"
#import "SHCFolder.h"
#import "SHCFileManager.h"
#import "SHCAPIManager.h"
#import "NSString+SHA1String.h"
#import "NSError+ExtraInfo.h"
#import "SHCBaseTableViewController.h"
#import "UIViewController+NeedsReload.h"
#import "SHCDocumentsViewController.h"
#import "SHCReceiptFoldersTableViewController.h"
#import "SHCInvoice.h"
#import "SHCMailbox.h"
#import "SHCRootResource.h"
#import "SHCModelManager.h"
#import "SHCReceipt.h"
#import "SHCFoldersViewController.h"
#import "SHCAttachmentsViewController.h"
#import "SHCDocumentsViewController.h"
#import "UILabel+Digipost.h"
#import "UIView+AutoLayout.h"
#import "SHCLetterPopoverTableViewDataSourceAndDelegate.h"
#import "SHCLetterPopoverTableViewMobelObject.h"
#import "UIBarButtonItem+DigipostBarButtonItems.h"
static void *kSHCLetterViewControllerKVOContext = &kSHCLetterViewControllerKVOContext;

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushLetterIdentifier = @"PushLetter";

// Google Analytics screen name
NSString *const kLetterViewControllerScreenName = @"Letter";

@interface SHCLetterViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate>

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
@property (assign, nonatomic, getter = isSendingInvoice) BOOL sendingInvoice;
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;

@property (weak, nonatomic) IBOutlet UIView *popoverView;
@property (weak, nonatomic) IBOutlet UITableView *popoverTableView;
@property (weak, nonatomic) IBOutlet UILabel *popoverTitleLabel;
- (IBAction)didTapClosePopoverButton:(id)sender;
@property (nonatomic,strong) SHCLetterPopoverTableViewDataSourceAndDelegate *popoverTableViewDataSourceAndDelegate;
@end

@implementation SHCLetterViewController

@synthesize attachment = _attachment;
@synthesize receipt = _receipt;

#pragma mark - NSObject

- (void)dealloc
{
    @try {
        [self.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) context:kSHCLetterViewControllerKVOContext];
    } @catch (NSException *exception) {
        DDLogDebug(@"Caught an exception: %@", exception);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDocumentsViewEditingStatusChangedNotificationName object:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.toolbar setBarTintColor:[UIColor colorWithRed:64.0/255.0 green:66.0/255.0 blue:69.0/255.0 alpha:0.95]];
    
    self.infoBarButtonItem = [UIBarButtonItem barButtonItemWithInfoImageForTarget:self action:@selector(didTapInfo:)];
    
    self.actionBarButtonItem = [UIBarButtonItem barButtonItemWithActionImageForTarget:self action:@selector(didTapAction:)];
    
    self.screenName = kLetterViewControllerScreenName;
    
    self.moveBarButtonItem.title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_MOVE_BUTTON_TITLE", @"Move");
    self.deleteBarButtonItem.title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_DELETE_BUTTON_TITLE", @"Delete");
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTapWebView:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    singleTapGestureRecognizer.delegate = self;
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapWebView:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    doubleTapGestureRecognizer.delegate = self;
    
    // To make sure this view only responds to single taps
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    
    [self.webView addGestureRecognizer:singleTapGestureRecognizer];
    [self.webView addGestureRecognizer:doubleTapGestureRecognizer];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeEditingStatus:) name:kDocumentsViewEditingStatusChangedNotificationName object:nil];
    }
    [self updateLeftBarButtonItem:self.navigationItem.leftBarButtonItem forViewController:self];
    [self reloadFromMetadata];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL toolbarHidden = NO;
    
    [self.navigationController setToolbarHidden:toolbarHidden animated:NO];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self updateNavbar];
}

- (void)didChangeEditingStatus: (NSNotification* )notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *isEditing = userInfo[kEditingStatusKey];
    [self.navigationController setToolbarHidden:[isEditing boolValue] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.view.window && self.navigationItem.leftBarButtonItem && self.masterViewControllerPopoverController) {
        [self.masterViewControllerPopoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unloadContent];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.progressView.alpha = 0.0;
    self.webView.alpha = 1.0;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //    self.progressView.alpha = 0.0;
    //    self.webView.alpha = 1.0;
    
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
                otherButtonTitles:@[NSLocalizedString(@"GENERIC_OPEN_IN_SAFARI_BUTTON_TITLE", @"Open in Safari")]
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
    
    UIViewController *topViewController = viewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        topViewController = ((UINavigationController *)viewController).topViewController;
    }
    
    [self updateLeftBarButtonItem:barButtonItem forViewController:topViewController];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.masterViewControllerPopoverController = nil;
    
    [self setInfoViewVisible:NO];
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
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
    } else if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Properties

- (SHCAttachment *)attachment
{
    return _attachment;
}

- (void)setAttachment:(SHCAttachment *)attachment
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
        [self reloadFromMetadata];
        // update the read status for ipad view
    }
}

- (void)setAttachmentDoNotDismissPopover:(SHCAttachment *)attachment {
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

- (SHCReceipt *)receipt
{
    return _receipt;
}

- (void)setReceipt:(SHCReceipt *)receipt
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

- (void)setReceiptDoNotDismissPopover:(SHCReceipt *)receipt
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
    NSString *moveTo = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_MOVE_TO_TITLE", @"Move to");
    
    NSMutableArray *destinations = [NSMutableArray array];
    
    NSString *inboxLocalizedName = [NSString stringWithFormat:@"%@ %@", moveTo, NSLocalizedString(@"FOLDER_NAME_INBOX", @"Inbox")];
    NSString *workAreaLocalizedName = [NSString stringWithFormat:@"%@ %@", moveTo, NSLocalizedString(@"FOLDER_NAME_WORKAREA", @"Workarea")];
    NSString *archiveLocalizedName = [NSString stringWithFormat:@"%@ %@", moveTo, NSLocalizedString(@"FOLDER_NAME_ARCHIVE", @"Archive")];
    
    NSString *documentLocation = self.attachment.document.location;
    if (![[documentLocation lowercaseString] isEqualToString:[kFolderInboxName lowercaseString]]) {
        [destinations addObject:inboxLocalizedName];
    }
    if (![[self.attachment.document.location lowercaseString] isEqualToString:[kFolderWorkAreaName lowercaseString]]) {
        [destinations addObject:workAreaLocalizedName];
    }
    if (![[self.attachment.document.location lowercaseString] isEqualToString:[kFolderArchiveName lowercaseString]]) {
        [destinations addObject:archiveLocalizedName];
    }
    NSString *title = nil;
    if ([self.attachment.document.attachments count] > 1) {
        title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_MOVE_WARNING_TITLE", @"Move warning");
    }
    
    [UIActionSheet showFromBarButtonItem:sender
                                animated:YES
                               withTitle:title
                       cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
                  destructiveButtonTitle:nil
                       otherButtonTitles:destinations
                                tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                    if (buttonIndex < [destinations count]) {
                                        NSString *location = destinations[buttonIndex] ;
                                        if ([location rangeOfString:inboxLocalizedName].location != NSNotFound) {
                                            [self moveDocumentToLocation:[kFolderInboxName uppercaseString]];
                                        } else if ( [location rangeOfString:workAreaLocalizedName].location != NSNotFound){
                                            [self moveDocumentToLocation:[kFolderWorkAreaName uppercaseString]];
                                        } else if ( [location rangeOfString:archiveLocalizedName].location != NSNotFound){
                                            [self moveDocumentToLocation:[kFolderArchiveName uppercaseString]];
                                        } else {
                                            NSAssert(NO, @"Wrong index tapped");
                                        }
                                    }
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

    SHCBaseEncryptedModel *baseEncryptionModel = nil;
    
    if (self.attachment) {
        baseEncryptionModel = self.attachment;
    } else if (self.receipt) {
        baseEncryptionModel = self.receipt;
    }
    
    NSString *encryptedFilePath = [baseEncryptionModel encryptedFilePath];
    NSString *decryptedFilePath = [baseEncryptionModel decryptedFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        NSError *error = nil;
        if (![[SHCFileManager sharedFileManager] decryptDataForBaseEncryptionModel:baseEncryptionModel error:&error]) {
            [self loadContentFromWebWithBaseEncryptionModel:baseEncryptionModel];
            return;
        }
        
        NSURL *fileURL = [NSURL fileURLWithPath:decryptedFilePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [self.webView loadRequest:request];
        
        [self updateToolbarItemsWithInvoice:(self.attachment.invoice != nil)];
    } else {
        [self loadContentFromWebWithBaseEncryptionModel:baseEncryptionModel];
    }
}

- (void)loadContentFromWebWithBaseEncryptionModel:(SHCBaseEncryptedModel *)baseEncryptionModel
{
    NSParameterAssert(baseEncryptionModel);
    NSProgress *progress = nil;
    self.progressView.progress = 0.0;
    
    if ([baseEncryptionModel isKindOfClass:[SHCAttachment class]]) {
        [UIView animateWithDuration:0.3 delay:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.alpha = 1.0;
        } completion:nil];
        
        progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        NSInteger fileSize = [self.attachment.fileSize integerValue];
        progress.totalUnitCount = (int64_t) fileSize;
        
        [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:kSHCLetterViewControllerKVOContext];
        
        self.progress = progress;
    }
    
    NSString *baseEncryptionModelUri = baseEncryptionModel.uri;
    
    [[SHCAPIManager sharedManager] downloadBaseEncryptionModel:baseEncryptionModel withProgress:progress success:^{
        
        // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
        SHCBaseEncryptedModel *changedBaseEncryptionModel = nil;
        if (self.attachment) {
            changedBaseEncryptionModel = [SHCAttachment existingAttachmentWithUri:baseEncryptionModelUri inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
        } else {
            changedBaseEncryptionModel = [SHCReceipt existingReceiptWithUri:baseEncryptionModelUri inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
        }
        
        NSError *error = nil;
        if (![[SHCFileManager sharedFileManager] encryptDataForBaseEncryptionModel:changedBaseEncryptionModel error:&error]) {
            [UIAlertView showWithTitle:error.errorTitle
                               message:[error localizedDescription]
                     cancelButtonTitle:nil
                     otherButtonTitles:@[error.okButtonTitle]
                              tapBlock:error.tapBlock];
        }
        
        NSURL *fileURL = [NSURL fileURLWithPath:[changedBaseEncryptionModel decryptedFilePath]];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [self.webView loadRequest:request];
        
        [self updateToolbarItemsWithInvoice:(self.attachment.invoice != nil)];
        
        if ([_attachment.read boolValue] == NO ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
        }
    } failure:^(NSError *error) {
        
        BOOL unauthorized = NO;
        
        if ([[error domain] isEqualToString:kAPIManagerErrorDomain] &&
            [error code] == SHCAPIManagerErrorCodeUnauthorized) {
            unauthorized = YES;
        } else {
            NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                if ([[SHCAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                    unauthorized = YES;
                }
            }
        }
        
        if (unauthorized) {
            // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
            SHCBaseEncryptedModel *changedBaseEncryptionModel = nil;
            if (self.attachment) {
                changedBaseEncryptionModel = [SHCAttachment existingAttachmentWithUri:baseEncryptionModelUri inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
            } else {
                changedBaseEncryptionModel = [SHCReceipt existingReceiptWithUri:baseEncryptionModelUri inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
            }
            
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

- (void)unloadContent
{
    [[SHCAPIManager sharedManager] cancelDownloadingBaseEncryptionModels];
    [[SHCFileManager sharedFileManager] removeAllDecryptedFiles];
}

- (BOOL)attachmentHasValidFileType
{
    // Receipts are always pdf's.
    if (self.receipt) {
        return YES;
    }
    
    // A list of file types that are tried and tested with UIWebView
    NSArray *validFilesTypes = @[@"pdf", @"png", @"jpg", @"jpeg", @"gif", @"php", @"doc", @"ppt", @"docx", @"xlsx", @"pptx", @"txt", @"html", @"numbers", @"key", @"pages"];
    
    return [validFilesTypes containsObject:self.attachment.fileType];
}

- (void)showInvalidFileTypeView
{
    self.errorLabel.text = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVALID_FILE_TYPE_MESSAGE", @"Invalid file type message");
    self.webView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.errorLabel.alpha = 1.0;
    }];
}

- (void)didSingleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    BOOL barsHidden = self.navigationController.isToolbarHidden;
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [self.navigationController setNavigationBarHidden:!barsHidden animated:YES];
        [self.navigationController setToolbarHidden:!barsHidden animated:YES];
        
        UIStatusBarStyle statusBarStyle = barsHidden ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
    }
}

- (void)didDoubleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"double tap");
}

- (void)moveDocumentToLocation:(NSString *)location
{
    NSAssert(self.attachment.document != nil, @"no document");
    
    [[SHCAPIManager sharedManager] moveDocument:self.attachment.document toLocation:location withSuccess:^{
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
        
    } failure:^(NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                // We were unauthorized, due to the session being invalid.
                // Let's retry in the next run loop
                [self performSelector:@selector(moveDocumentToLocation:) withObject:location afterDelay:0.0];
                
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
    [[SHCAPIManager sharedManager] deleteDocument:self.attachment.document withSuccess:^{
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
            //            [self showEmptyView:YES];
        }
    } failure:^(NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
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
    [[SHCAPIManager sharedManager] deleteReceipt:self.receipt withSuccess:^{
        
        _receipt = nil;
        if (self.receiptsViewController) {
            self.receiptsViewController.needsReload = YES;
            
            // Becuase we might have been pushed from the attachments vc, make sure that we pop
            // all the way back to the documents vc.
            [self.navigationController popToViewController:self.receiptsViewController animated:YES];
        }
    } failure:^(NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
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
    
    if (!self.openInController) {
        
        SHCBaseEncryptedModel *baseEncryptionModel = nil;
        
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
            if (![[SHCFileManager sharedFileManager] decryptDataForBaseEncryptionModel:baseEncryptionModel error:&error]) {
                [UIAlertView showWithTitle:error.errorTitle
                                   message:[error localizedDescription]
                         cancelButtonTitle:nil
                         otherButtonTitles:@[error.okButtonTitle]
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
        [self.openInController presentOpenInMenuFromBarButtonItem:barButtonItem animated:YES];
    }else {
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
    
    [UIAlertView showWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:@[actionButtonTitle] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
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
            self.popoverTableViewDataSourceAndDelegate = [[SHCLetterPopoverTableViewDataSourceAndDelegate alloc]init];
        }
        
        NSMutableArray *mutableObjectsInMetadata = [NSMutableArray array];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // Dateformatter for format: 13.02.2013 kl. 09.49 - Digipost format
        [dateFormatter setDateFormat:@"dd.MM.YYYY 'kl.' hh.mm"];
        
        self.popoverTitleLabel.text = self.attachment.subject;
        if (self.attachment) {
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_TITLE", @"From") description:self.attachment.document.creatorName]];
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle: NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_DATE_TITLE", @"Date") description:[dateFormatter stringFromDate:self.attachment.document.createdAt]]];
            
        } else if (self.receipt) {
            self.popoverTitleLabel.text = self.receipt.storeName;
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle: NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_DATE_TITLE", @"Date") description:[dateFormatter stringFromDate:self.receipt.timeOfPurchase]]];
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_AMOUNT", @"Beløp") description:[NSString stringWithFormat:@"%@",[SHCReceipt stringForReceiptAmount: self.receipt.amount]]]];
            
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_RECEIPT", @"Kort") description: [NSString stringWithFormat:@"%@",self.receipt.card]]];
        }
        
        if (self.attachment.invoice){
            
            NSString *invoiceAmount = [SHCInvoice stringForInvoiceAmount:self.attachment.invoice.amount];
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_AMOUNT", @"Beløp") description:invoiceAmount]];
            
            [dateFormatter setDateFormat:@"dd.MM.YYYY"];
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_DUEDATE", @"Forfallsdato") description:[dateFormatter stringFromDate:self.attachment.invoice.dueDate]]];
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_TO_ACCOUNT", @"Til konto") description:self.attachment.invoice.accountNumber]];
            [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_KID", @"KID") description:[NSString stringWithFormat:@"%@",self.attachment.invoice.kid]]];
            NSString *statusDescriptionText = [self.attachment.invoice statusDescriptionText];
            if (statusDescriptionText) {
                [mutableObjectsInMetadata addObject:[SHCLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_STATUS", @"Status") description:statusDescriptionText]];
            }
        }
        
        self.popoverTableView.delegate = self.popoverTableViewDataSourceAndDelegate;
        self.popoverTableView.dataSource = self.popoverTableViewDataSourceAndDelegate;
        self.popoverTableViewDataSourceAndDelegate.lineObjects = mutableObjectsInMetadata;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.shadowView.alpha = 1.0;
        }];
        
        [self.navigationController.toolbar setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
        [self.navigationController.toolbar setUserInteractionEnabled:NO];
        [self.popoverTableView reloadData];
        
    } else if (!visible && self.shadowView.alpha == 1.0) {
        [UIView animateWithDuration:0.2 animations:^{
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
    
    [[SHCAPIManager sharedManager] sendInvoiceToBank:self.attachment.invoice withSuccess:^{
        
        // Now, we've successfully sent the invoice to the bank, but we still need updated document metadata
        // to be able to correctly display the contents of the alertview if the user taps the "sent to bank" button.
        [self updateDocuments];
        
    } failure:^(NSError *error) {
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
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
    if ([SHCAPIManager sharedManager].isUpdatingDocuments) {
        return;
    }
    
    NSString *attachmentUri = self.attachment.uri;
    
    [[SHCAPIManager sharedManager] updateDocumentsInFolderWithName:self.attachment.document.folder.name folderUri:self.attachment.document.folder.uri success:^{
        [self updateAttachmentWithAttachmentUri:attachmentUri];
        self.sendingInvoice = NO;
        [self updateToolbarItemsWithInvoice:YES];
    } failure:^(NSError *error) {
        
        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
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
    self.attachment = [SHCAttachment existingAttachmentWithUri:uri inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
}

- (void)updateToolbarItemsWithInvoice:(BOOL)invoice
{
    UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
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
        
        self.invoiceBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(didTapInvoice:)];
        self.invoiceBarButtonItem.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self.invoiceBarButtonItem setEnabled:!self.isSendingInvoice];
        
        if (self.attachment) {
            [items addObjectsFromArray:@[self.moveBarButtonItem, flexibleSpaceBarButtonItem]];
        }
        [items addObjectsFromArray:@[self.invoiceBarButtonItem]];
        [items addObjectsFromArray:@[flexibleSpaceBarButtonItem, self.deleteBarButtonItem]];
        
        self.toolbarItems = items;
    } else {
        if (self.attachment) {
            [items addObject:self.moveBarButtonItem];
            [items addObjectsFromArray:@[flexibleSpaceBarButtonItem, self.deleteBarButtonItem]];
        }else if (self.receipt)  {
            [items addObjectsFromArray:@[flexibleSpaceBarButtonItem, self.deleteBarButtonItem]];
            
        }
        if ([items count] > 0) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        } else {
            [self.navigationController setToolbarHidden:YES animated:YES];
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
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:YES];
}

- (void)showEmptyView:(BOOL)showEmptyView
{
    if (showEmptyView) {
        self.webView.alpha = 0.0;
    }
    
    self.emptyLetterViewImageView.hidden = !showEmptyView;
    [self updateToolbarItemsWithInvoice:NO];
}

- (void)updateNavbar
{
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
    
    if (self.attachment || self.receipt) {
        [rightBarButtonItems addObjectsFromArray:@[self.actionBarButtonItem, self.infoBarButtonItem]];
    }
    
    self.navigationItem.rightBarButtonItems = [rightBarButtonItems count] > 0 ? rightBarButtonItems : nil;
}

- (void)reloadFromMetadata
{
    [self updateNavbar];
    
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
}

- (IBAction)didTapClosePopoverButton:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.shadowView.alpha = 0.0;
    }];
    
    [self.navigationController.toolbar setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
    [self.navigationController.toolbar setUserInteractionEnabled:YES];
}
@end
