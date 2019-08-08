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

#import <UIAlertView_Blocks/UIAlertView+Blocks.h>
#import "POSLetterViewController.h"
#import "POSAttachment.h"
#import "POSDocument.h"
#import <AHKActionSheet/AHKActionSheet.h>
#import "POSFolder+Methods.h"
#import "POSFileManager.h"
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
#import "POSInvoice.h"
#import <MRProgress/MRProgress.h>
#import "POSMailbox.h"
#import "POSRootResource.h"
#import "POSModelManager.h"
#import "POSFoldersViewController.h"
#import "SHCAttachmentsViewController.h"
#import "POSDocumentsViewController.h"
#import "UILabel+Digipost.h"
#import "UIView+AutoLayout.h"
#import "SHCOAuthViewController.h"
#import "POSLetterPopoverTableViewDataSourceAndDelegate.h"
#import "POSLetterPopoverTableViewMobelObject.h"
#import "UIBarButtonItem+DigipostBarButtonItems.h"
static void *kSHCLetterViewControllerKVOContext = &kSHCLetterViewControllerKVOContext;

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushLetterIdentifier = @"PushLetter";
NSString *const kaskForhigherAuthenticationLevelSegue = @"askForhigherAuthenticationLevelSegue";
NSString *const kinvoiceOptionsSegue = @"invoiceOptionsSegue";

// Google Analytics screen name
NSString *const kLetterViewControllerScreenName = @"Letter";

@interface POSLetterViewController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate, UIScrollViewDelegate, SHCOAuthViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *informationBarButtonItem;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyLetterViewImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popoverViewHeightConstraint;
@property (strong, nonatomic) UIBarButtonItem *infoBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *actionBarButtonItem;
@property (strong, nonatomic) NSProgress *progress;
@property (strong, nonatomic) UIDocumentInteractionController *openInController;
@property (strong, nonatomic) UIBarButtonItem *invoiceBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView *popoverView;
@property (weak, nonatomic) IBOutlet UITableView *popoverTableView;
@property (weak, nonatomic) IBOutlet UILabel *popoverTitleLabel;
@property (nonatomic) CGFloat lastDragStartY;
@property (nonatomic, strong) POSLetterPopoverTableViewDataSourceAndDelegate *popoverTableViewDataSourceAndDelegate;
@property (nonatomic, weak) UnlockHighAuthenticationLevelView *unlockView;
- (IBAction)didTapClosePopoverButton:(id)sender;
- (IBAction)didTapInformationBarButtonItem:(id)sender;

// Metadata
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIScrollView *innerScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *metaContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;

// just a helper function that lets us fetch current attachment if its been nilled out by Core data
@property (nonatomic, strong) NSString *currentAttachmentURI;

@end

@implementation POSLetterViewController

@synthesize attachment = _attachment;

//helpers to adjust showing/hiding metadata views
CGFloat extraMetadataConstraintHeight = 0;

#pragma mark - NSObject

- (void)dealloc
{
    @try {
        [self.progress removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                              context:kSHCLetterViewControllerKVOContext];
    }
    @catch (NSException *exception) {
        //        DDLogDebug(@"Caught an exception: %@", exception);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDocumentsViewEditingStatusChangedNotificationName
                                                  object:nil];
    if (self.attachment) {
        NSString *currentScope = [OAuthToken oAuthScopeForAuthenticationLevel:self.attachment.authenticationLevel];
        if (currentScope != kOauth2ScopeFull) {
            [self.attachment deleteDecryptedFileIfExisting];
            [self.attachment deleteEncryptedFileIfExisting];
        }
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scrollView.bounces = FALSE;
    self.webView.backgroundColor = [UIColor digipostLightGrey];
    
    if ([self.attachment.fileType isEqualToString:@"html"]) {
        self.webView.backgroundColor = [UIColor whiteColor];
    }
    if (self.attachment) {
        [self setTitle:self.attachment.subject];
    }
    self.screenName = kLetterViewControllerScreenName;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeEditingStatus:)
                                                     name:kDocumentsViewEditingStatusChangedNotificationName
                                                   object:nil];
    }
    [self reloadFromMetadata];
    [InvoiceBankAgreement updateActiveBankAgreementStatus];

    [self addTapGestureRecognizersToWebView:self.webView];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self updateLeftBarButtonItem:self.navigationItem.leftBarButtonItem
                    forViewController:self];
        [self updateLeftBarButtonForIpad];
    }
}

- (void)updateLeftBarButtonForIpad
{
    UIBarButtonItem *leftBarButtonItem = self.leftBarButtonItem;
        if (!leftBarButtonItem) {
            leftBarButtonItem = self.navigationItem.leftBarButtonItem;
        }
        [leftBarButtonItem setImage:[UIImage imageNamed:@"icon-navbar-drawer"]];
        leftBarButtonItem.title = @" ";
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem
                                         animated:YES];
        [leftBarButtonItem setAction:@selector(showSideMenu:)];
        [leftBarButtonItem setTarget:self];
    
}

- (void)shouldValidateOpeningReceipt:(POSAttachment *)attachment
{
    NSString *documentURI = attachment.document.updateUri;
    POSDocument *document = attachment.document;

    [[APIClient sharedClient] validateOpeningReceipt:attachment
        success:^{

          [[APIClient sharedClient] updateDocument:document
              success:^(NSDictionary *responseDict) {
                  POSDocument *refetchedDocument = [POSDocument existingDocumentWithUpdateUri:documentURI inManagedObjectContext:[[POSModelManager sharedManager] managedObjectContext]];
                  [[POSModelManager sharedManager] updateDocument:refetchedDocument
                                                 withAttributes:responseDict];
                if (self.currentAttachmentURI == nil) {
                    self.attachment = document.attachments[self.indexOfAttachment];
                } else {
                    self.attachment = [POSAttachment existingAttachmentWithUri:self.currentAttachmentURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                    self.attachment.openingReceiptUri = nil;
                }

                [[POSModelManager sharedManager] logSavingManagedObjectContext];
                [self downloadAttachmentContent:self.attachment];
              }
              failure:^(APIError *error) {
                  [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
              }];

        }
        failure:^(APIError *error) {
          [UIAlertView showWithTitle:NSLocalizedString(@"Failed validating opening receipt title", @"title of alert telling user validation failed")
                             message:@""
                   cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                   otherButtonTitles:@[]
                            tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              [self.navigationController popViewControllerAnimated:YES];
                            }];
        }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kaskForhigherAuthenticationLevelSegue]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SHCOAuthViewController *oAuthViewController = (SHCOAuthViewController *)navigationController.topViewController;
        oAuthViewController.delegate = self;
        oAuthViewController.scope = [OAuthToken oAuthScopeForAuthenticationLevel:self.attachment.authenticationLevel];
    }else if ([segue.identifier isEqualToString:kinvoiceOptionsSegue]) {
        NSString *invoiceTitle = self.attachment.subject;
        InvoiceOptionsViewController *invoiceOptionsViewController = (InvoiceOptionsViewController*) segue.destinationViewController;
        invoiceOptionsViewController.title = invoiceTitle;
    }else if ([segue.identifier isEqualToString:@"showExternalLinkWebview"]) {
        ExternalLinkWebview *externalLinkWebview = (ExternalLinkWebview*) segue.destinationViewController;
        externalLinkWebview.initUrl = (NSString *)sender;
    }
}

-(void)openExternalLink:(NSString*) url {
    NSURL *urlObject = [NSURL URLWithString:url];
    
    if([urlObject.scheme isEqual: @"https"]) {
        [self performSegueWithIdentifier:@"showExternalLinkWebview" sender:url];
    } else{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:[urlObject host]
                                     message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* open = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"GENERIC_OPEN_IN_SAFARI_BUTTON_TITLE", @"Open in Safari")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [[UIApplication sharedApplication] openURL:urlObject];
                               }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle: NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action){}];
        [alert addAction:open];
        [alert addAction:cancel];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat yStartValue = scrollView.contentOffset.y;
    self.lastDragStartY = yStartValue;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (targetContentOffset->y == self.lastDragStartY) {
        return;
    }
}

- (void)viewWillLayoutSubviews
{
    NSArray *toolbarItems = [self.navigationController.toolbar setupIconsForLetterViewController:self];
    [self setToolbarItems:toolbarItems animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden: NO animated:YES];
    if (![OAuthToken isUserLoggedIn]){
        [self.webView loadHTMLString:@"" baseURL:nil];
    }
    [super viewWillAppear:animated];
}

- (void)didChangeEditingStatus:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *isEditing = userInfo[kEditingStatusKey];
    [self.navigationController setToolbarHidden:[isEditing boolValue]
                                       animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unloadContent];

    if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }


    [super viewDidDisappear:animated];
}

- (void)didSingleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    // this feature should not be activated if voiceover is running
    if (UIAccessibilityIsVoiceOverRunning()) {
        return;
    }

}

- (void)didDoubleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
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
            }
        }
        v = [v.subviews firstObject];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.progressView.alpha = 0.0;
    self.webView.alpha = 1.0;
    if ([self.attachment.fileType isEqualToString:@"html"]) {
        self.webView.backgroundColor = [UIColor whiteColor];
    }
    [self.webView setAccessabilityLabelForFileType:self.attachment.fileType];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //    DDLogError(@"%@", [error localizedDescription]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL absoluteString] isEqualToString:@"about:blank"]) {
        return YES;
    } else if ([request.URL isFileURL]) {
        return YES;
    } else {
        [self openExternalLink: request.URL.absoluteString];
        return NO;
    }
    return NO;
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
    POSBaseEncryptedModel *baseEncryptionModel = nil;

    if (self.attachment) {
        baseEncryptionModel = self.attachment;
        [baseEncryptionModel deletefileAtHumanReadablePath];
    }
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
    // if attachment is refreshed in background, it can be "lost", just refetch it, to get it back
    if (_attachment == nil) {
        if (self.currentAttachmentURI) {
            _attachment = [POSAttachment existingAttachmentWithUri:self.currentAttachmentURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        }
    } else if (_attachment.uri == nil) {
        if (self.currentAttachmentURI) {
            _attachment = [POSAttachment existingAttachmentWithUri:self.currentAttachmentURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        }
    }
    return _attachment;
}

- (void)setAttachment:(POSAttachment *)attachment
{
    [self unloadContent];

    self.errorLabel.alpha = 0;
    BOOL new = attachment != _attachment;

    if (new) {
        if (attachment.needsAuthenticationToOpen) {
            [attachment deleteDecryptedFileIfExisting];
            [attachment deleteEncryptedFileIfExisting];
        }
    }
    _attachment = attachment;

    // used to fetch attachment if something has deleted it from store and reinserted it
    self.currentAttachmentURI = attachment.uri;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (self.masterViewControllerPopoverController) {
            [self.masterViewControllerPopoverController dismissPopoverAnimated:YES];
        }

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

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        [self showEmptyView:new];
        [self reloadFromMetadata];
        // update the read status for ipad view
    }
}

#pragma mark - IBActions

- (void)showBlurredActionSheetWithFolders
{
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:NSLocalizedString(@"navbar title upload folder", @"Choose folder")];
    [actionSheet setupStyle];
    POSDocumentsViewController *documentsViewController;
    POSFoldersViewController *foldersViewController;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        for (UIViewController *viewController in self.splitViewController.viewControllers) {
            if ([viewController isKindOfClass:[UINavigationController class]]) {
                for (UIViewController *subViewController in((UINavigationController *)viewController).viewControllers) {
                    if ([subViewController isKindOfClass:[POSFoldersViewController class]]) {
                        foldersViewController = (id)subViewController;
                    }
                    if ([subViewController isKindOfClass:[POSDocumentsViewController class]]) {
                        documentsViewController = (id)subViewController;
                    }
                }
            }
        }
    } else {
        documentsViewController = self.documentsViewController;
    }
    NSArray *folders;
    if (documentsViewController == nil) {
        folders = [POSFolder foldersForUserWithMailboxDigipostAddress:foldersViewController.selectedMailBoxDigipostAdress
                                               inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    } else {
        folders = [POSFolder foldersForUserWithMailboxDigipostAddress:documentsViewController.mailboxDigipostAddress
                                               inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    }

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
                                    handler:^(AHKActionSheet *actionSheet) {
                                      [self moveDocument:self.attachment.document toFolder:folder];
                                    }];
        }
    }

    [actionSheet show];
}

- (void)moveDocument:(POSDocument *)document toFolder:(POSFolder *)folder
{
    NSParameterAssert(document);
    [[APIClient sharedClient] moveDocument:document
        toFolder:folder
        success:^{
          document.folder = folder;
          [[POSModelManager sharedManager].managedObjectContext save:nil];
          if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
              if ([self.attachment.document isEqual:document]) {
                  self.attachment = nil;
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
          } else {
              [self.navigationController popToViewController:self.documentsViewController animated:YES];
          }
        }
        failure:^(APIError *error) {
            [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
        }];
}

- (IBAction)dismissInfo:(UIGestureRecognizer *)gestureRecognizer
{
    [self setInfoViewVisible:NO];
}

#pragma mark - Private methods

- (void)loadFileURL:(NSURL *)fileURL
{
    if ([self.attachment.fileType.lowercaseString isEqualToString:@"jpg"]) {
        NSString *html = [NSString stringWithFormat:@"<img src='%@' style='width:100%%; margin: 0px 0px;'>", fileURL];
        [self.webView loadHTMLString:html baseURL:nil];
    } else if ([self.attachment.fileType isEqualToString:@"html"]) {
        self.webView.backgroundColor = [UIColor whiteColor];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [self.webView loadRequest:request];
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [self.webView loadRequest:request];
    }
    [self showInvoiceSetupAlertIfNoActiveAgreements];
    [self removeUnlockViewIfPresent];
}

- (void)setTitle:(NSString *)title {
    self.navigationItem.leftItemsSupplementBackButton = true;
    self.navigationItem.title = title;
}

- (void)loadContent
{    
    POSBaseEncryptedModel *baseEncryptionModel = nil;
    if (self.attachment) {
        baseEncryptionModel = self.attachment;
    }
    if (self.attachment) {
        [self setTitle:self.attachment.subject];
    }
   
    if ([self isUserKeyEncrypted]) {
        [self showLockedViewCanBeUnlocked:NO];
        return;
    }
/*
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
        [self loadFileURL:fileURL];
    } else {
        [self loadContentFromWebWithBaseEncryptionModel:baseEncryptionModel];
    }
 */
    [self loadContentFromWebWithBaseEncryptionModel:baseEncryptionModel];
    if(self.attachment){
        [self updateCurrentDocument];
    }
    NSArray *toolbarItems = [self.navigationController.toolbar setupIconsForLetterViewController:self];
    [self setToolbarItems:toolbarItems animated:YES];
}

- (void)loadMetadataContent
{
    [self removeOldMetadataViews];
    if(self.attachment.metadata != nil) {
        CGFloat extraHeight = 0;
        extraMetadataConstraintHeight = 0;
        
        NSArray *metadataArray = self.attachment.getMetadataArray;

         for(POSMetadataObject *metadataObject in metadataArray) {
            if([metadataObject isKindOfClass:[POSAppointment class]]) {
                AppointmentView *appointmentView = [[[AppointmentView alloc] init] instanceWithDataWithAppointment: (POSAppointment *) metadataObject];
                [_stackView addArrangedSubview:appointmentView];
                extraHeight += appointmentView.frame.size.height;
            }else if([metadataObject isKindOfClass:[POSEvent class]]) {
                EventView *eventView = [[[EventView alloc] init] instanceWithDataWithEvent:(POSEvent*) metadataObject title:_attachment.subject];
                [eventView setParentViewController: self];
                [_stackView addArrangedSubview:eventView];
                extraHeight += eventView.frame.size.height;
            }else if([metadataObject isKindOfClass:[POSExternalLink class]]) {
                ExternalLinkView *externalLinkView = [[[ExternalLinkView alloc] init] instanceWithDataWithExternalLink: (POSExternalLink *) metadataObject];
                [externalLinkView setParentViewController: self];
                [_stackView addArrangedSubview:externalLinkView];
                extraHeight += externalLinkView.frame.size.height;
            }
         }
        
        if(extraHeight > 0) {
            [AppointmentView requestPermissions];
        }

        extraMetadataConstraintHeight += extraHeight;
        [self updateViewHeights:extraHeight];
    }
}

- (void) removeOldMetadataViews
{
    if ([[_stackView subviews] count] > 0) {
        if(extraMetadataConstraintHeight > 0) {
            [self updateViewHeights:-extraMetadataConstraintHeight];
            extraMetadataConstraintHeight = 0;
        }
    
        for(UIView *view in [_stackView subviews]){
            [_stackView removeArrangedSubview:view];
            [view removeFromSuperview];
        }
    }
}

-(void)updateViewHeights: (CGFloat ) height
{
    self.contentViewHeight.constant += height;
    self.metaContentHeight.constant += height;
}

-(void)updateCurrentDocument
{
    [[APIClient sharedClient] updateDocument:self.attachment.document
                                     success:^(NSDictionary *responseDict) {
                                         POSDocument *refetchedDocument = [POSDocument existingDocumentWithUpdateUri:self.attachment.document.updateUri inManagedObjectContext:[[POSModelManager sharedManager] managedObjectContext]];
                                         [[POSModelManager sharedManager] updateDocument:refetchedDocument withAttributes:responseDict];

                                         NSArray *toolbarItems = [self.navigationController.toolbar setupIconsForLetterViewController:self];
                                         [self setToolbarItems:toolbarItems animated:YES];

                                         [self.navigationController setToolbarHidden:[self shouldHideToolBar:self.attachment] animated:YES];
                                         [self loadMetadataContent];
                                     }failure:^(APIError *error) {
                                         [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
                                     }
     ];
}

- (void)downloadAttachmentContent:(POSAttachment *)attachment
{
    [[APIClient sharedClient] downloadBaseEncryptionModel:attachment
        withProgress:self.progress
        success:^{
          NSError *error = nil;
            
           /*
          if (![[POSFileManager sharedFileManager] encryptDataForBaseEncryptionModel:attachment error:&error]) {
              [UIAlertView showWithTitle:error.errorTitle
                                 message:[error localizedDescription]
                       cancelButtonTitle:nil
                       otherButtonTitles:@[ error.okButtonTitle ]
                                tapBlock:error.tapBlock];
          }
            */
          if ([self.attachment.fileType isEqualToString:@"html"]) {
              self.view.backgroundColor = [UIColor whiteColor];
          }

          NSURL *fileURL = [NSURL fileURLWithPath:[attachment decryptedFilePath]];
          [self loadFileURL:fileURL];

          if ([_attachment.read boolValue] == NO) {
              [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
          }
        }
        failure:^(APIError *error) {
          if (self.attachment.needsAuthenticationToOpen) {
              [self showLockedViewCanBeUnlocked:YES];
          }
        }];
}

- (void)loadContentFromWebWithBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel
{
    NSParameterAssert(baseEncryptionModel);

    NSProgress *progress = nil;
    [[APIClient sharedClient] cancelLastDownloadingBaseEncryptionModel];

    self.progressView.progress = 0.0;
    if ([self needsAuthenticationToOpen]) {
        [self showLockedViewCanBeUnlocked:YES];
        return;
    }
    if ([self isUserKeyEncrypted]) {
        [self showLockedViewCanBeUnlocked:NO];
        return;
    }
    if ([baseEncryptionModel isKindOfClass:[POSAttachment class]]) {
        [UIView animateWithDuration:0.1
                              delay:0.6
         
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             if ([self needsAuthenticationToOpen] == NO) {
                                 self.progressView.alpha = 1.0;
                                 self.webView.alpha = 0.0;
                             }
                         }
                         completion:^(BOOL finished){
                         }];
        if ([self.progress respondsToSelector:@selector(removeObserver:forKeyPath:context:)]) {
            [self.progress removeObserver:self
                               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                                  context:kSHCLetterViewControllerKVOContext];
        }
        NSInteger fileSize = [self.attachment.fileSize integerValue];
        progress = [NSProgress progressWithTotalUnitCount:(int64_t) fileSize];
        [progress addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                      options:NSKeyValueObservingOptionNew
                      context:kSHCLetterViewControllerKVOContext];
        self.progress = progress;
    }

    NSString *baseEncryptionModelUri = baseEncryptionModel.uri;

    if (baseEncryptionModelUri == nil && self.attachment.openingReceiptUri != nil) {
        POSAttachment *attachment = (id)baseEncryptionModel;
        __block POSDocument *document = attachment.document;
        NSString *subject = attachment.subject;
        NSString *updateURI = document.updateUri;

        [[APIClient sharedClient] updateDocument:attachment.document
            success:^(NSDictionary *responseDictionary) {
              [[POSModelManager sharedManager] updateDocument:attachment.document
                                               withAttributes:responseDictionary];
              [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
              [self removeUnlockViewIfPresent];

              // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
              __block POSBaseEncryptedModel *changedBaseEncryptionModel = self.attachment;
              document = [POSDocument existingDocumentWithUpdateUri:updateURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
              [document.attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                POSAttachment *attachment = (id)obj;
                if ([attachment.subject isEqualToString:subject]) {
                    changedBaseEncryptionModel = attachment;
                }
              }];
              [[APIClient sharedClient] downloadBaseEncryptionModel:changedBaseEncryptionModel
                  withProgress:progress
                  success:^{
                    NSError *error = nil;
                      /*
                    if (![[POSFileManager sharedFileManager] encryptDataForBaseEncryptionModel:changedBaseEncryptionModel error:&error]) {
                        [UIAlertView showWithTitle:error.errorTitle
                                           message:[error localizedDescription]
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@[ error.okButtonTitle ]
                                          tapBlock:error.tapBlock];
                    }
                       */
                    if ([self.attachment.fileType isEqualToString:@"html"]) {
                        self.view.backgroundColor = [UIColor whiteColor];
                    }

                    NSURL *fileURL = [NSURL fileURLWithPath:[changedBaseEncryptionModel decryptedFilePath]];
                    [self loadFileURL:fileURL];

                    if ([_attachment.read boolValue] == NO) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
                    }
                  }
                  failure:^(APIError *error) {
                    if (self.attachment.needsAuthenticationToOpen) {
                        [self showLockedViewCanBeUnlocked:YES];
                    }
                  }];
            }
            failure:^(APIError *error) {
              // show upload view controller here
              [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
            }];
    } else {
        [[APIClient sharedClient] downloadBaseEncryptionModel:baseEncryptionModel
            withProgress:progress
            success:^{

              [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];

              // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
              POSBaseEncryptedModel *changedBaseEncryptionModel = nil;
              if (self.attachment) {
                  changedBaseEncryptionModel = [POSAttachment existingAttachmentWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
              }

                NSError *error = nil;
                /*
              if
                 (![[POSFileManager sharedFileManager] encryptDataForBaseEncryptionModel:changedBaseEncryptionModel error:&error]) {
                  [UIAlertView showWithTitle:error.errorTitle
                                     message:[error localizedDescription]
                           cancelButtonTitle:nil
                           otherButtonTitles:@[ error.okButtonTitle ]
                                    tapBlock:error.tapBlock];
              }
                                   */
              if (changedBaseEncryptionModel == nil) {
                  return;
              }
              NSURL *fileURL = [NSURL fileURLWithPath:[changedBaseEncryptionModel decryptedFilePath]];
              [self loadFileURL:fileURL];

              if ([_attachment.read boolValue] == NO) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
              }
            }
            failure:^(APIError *error) {

              [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
              if ([self needsAuthenticationToOpen] == NO) {
                  [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
              }
            }];
    }
}

- (void)showLockedViewCanBeUnlocked:(BOOL) canBeUnlocked
{
    if ([self needsAuthenticationToOpen] || [self isUserKeyEncrypted]) {
        if (self.unlockView == nil) {
            NSArray *theView = [[NSBundle mainBundle] loadNibNamed:@"UnlockHighAuthenticationLevelView" owner:self options:nil];
            self.unlockView = [theView objectAtIndex:0];
            [self.view addSubview:self.unlockView];
            [self.unlockView needsUpdateConstraints];
            self.unlockView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.origin.y + 20);
            [self.unlockView setup:canBeUnlocked];
            [self.unlockView.unlockButton addTarget:self action:@selector(didTapUnlockButton:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            self.unlockView.alpha = 1;
            if (self.unlockView.superview == nil) {
                [self.view addSubview:self.unlockView];
            }
            [self.view bringSubviewToFront:self.unlockView];
        }
    }
}

- (void)removeUnlockViewIfPresent
{
    if (self.unlockView) {
        [UIView animateWithDuration:0.4
            animations:^{
              self.unlockView.alpha = 0.0;
            }
            completion:^(BOOL finished) {
              [self.unlockView removeFromSuperview];
              self.unlockView = nil;
            }];
    }
}

- (void)unloadContent
{
    [[POSFileManager sharedFileManager] removeAllDecryptedFiles];
    if (self.attachment.authenticationLevel) {
        // for added security on higher authentication level files, we prefer users to download the file every time it is opened, and delted immedeately after user navigates away from the file.
        NSString *currentScope = [OAuthToken oAuthScopeForAuthenticationLevel:self.attachment.authenticationLevel];
        if (currentScope != kOauth2ScopeFull) {
            [self.attachment deleteEncryptedFileIfExisting];
        }
    }
    
}

- (BOOL)attachmentHasValidFileType
{
    // A list of file types that are tried and tested with UIWebView
    NSArray *validFilesTypes = @[ @"pdf", @"png", @"jpg", @"jpeg", @"gif", @"php", @"doc", @"ppt", @"docx", @"docm", @"xml", @"xlsx", @"pptx", @"txt", @"html", @"numbers", @"key", @"pages" ];
    return [validFilesTypes containsObject:self.attachment.fileType];
}

- (BOOL)needsAuthenticationToOpen
{
    if (self.attachment) {
        return self.attachment.needsAuthenticationToOpen;
    } else
        return NO;
}

- (BOOL)isUserKeyEncrypted {
    if (self.attachment) {
        return self.attachment.userKeyEncrypted.boolValue;
    } else {
        return NO;
    }
}

- (void)showInvalidFileTypeView
{
    self.errorLabel.text = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVALID_FILE_TYPE_MESSAGE", @"Invalid file type message");
    self.webView.hidden = true;
    [UIView animateWithDuration:0.3
                     animations:^{
                       self.errorLabel.alpha = 1.0;
                     }];
}

- (void)moveDocumentToFolder:(POSFolder *)folder
{
    NSAssert(self.attachment.document != nil, @"no document");

    [[APIClient sharedClient] moveDocument:self.attachment.document
        toFolder:folder
        success:^{
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
        failure:^(APIError *error) {
            [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
        }];
}

- (void)deleteDocument
{
    NSAssert(self.attachment != nil, @"no attachment document to delete");
    [[APIClient sharedClient] deleteDocument:self.attachment.document.deleteUri
        success:^{
          _attachment = nil;
          if (self.documentsViewController) {
              self.documentsViewController.needsReload = YES;
              // Becuase we might have been pushed from the attachments vc, make sure that we pop
              // all the way back to the documents vc.
              [self.navigationController popToViewController:self.documentsViewController animated:YES];
          }
          if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
              [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
              [self showEmptyView:YES];
          }
        }
        failure:^(APIError *error) {
            [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
        }];
}

- (void)didTapInfo:(UIBarButtonItem *)barButtonItem
{
    BOOL shouldBeVisible = (self.shadowView.alpha == 0.0) ? YES : NO;

    [self setInfoViewVisible:shouldBeVisible];
}

- (void)didTapAction:(UIBarButtonItem *)barButtonItem
{
}

- (void)showRenameAlertView
{
    POSDocument *document = self.attachment.document;

    UIAlertView *alertView = [UIAlertView showWithTitle:NSLocalizedString(@"edit document name alert title", @"")
                                                message:NSLocalizedString(@"", @"")
                                                  style:UIAlertViewStylePlainTextInput
                                      cancelButtonTitle:NSLocalizedString(@"edit document name alert cancel button title", @"Cancel")
                                      otherButtonTitles:@[ NSLocalizedString(@"edit document alert ok button title", @"") ]
                                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                 if (buttonIndex == 1) {
                                                     NSString *name = [alertView textFieldAtIndex:0].text;
                                                     // do the actual change!
                                                     [[APIClient sharedClient] changeName:document
                                                         newName:name
                                                         success:^{
                                                           self.navigationItem.title = name;
                                                           self.attachment.subject = name;
                                                           [self loadContent];
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName object:nil];
                                                         }
                                                         failure:^(APIError *error) {
                                                             [UIAlertController presentAlertControllerWithAPIError:error presentingViewController:self];
                                                         }];
                                                 }
                                               }];
    [alertView textFieldAtIndex:0].text = self.attachment.subject;
}

- (BOOL)showOpenInControllerFromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    BOOL didOpenFile = false;
    if (self.openInController == nil) {

        POSBaseEncryptedModel *baseEncryptionModel = nil;
        NSString *subject;
        if (self.attachment) {
            baseEncryptionModel = self.attachment;
            subject = self.attachment.subject;
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
                return false;
            }
            fileURL = [NSURL fileURLWithPath:decryptedFilePath];
        } else {
            return false;
        }
        NSString *humanReadableURL = [baseEncryptionModel humanReadablePathWithTitle:subject];
        self.openInController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:humanReadableURL]];
        self.openInController.delegate = self;
        if (barButtonItem) {
            didOpenFile = [self.openInController presentOpenInMenuFromBarButtonItem:barButtonItem animated:YES];
        } else {
            UIBarButtonItem *barButtonItem = self.toolbarItems.lastObject;
            didOpenFile = [self.openInController presentOpenInMenuFromBarButtonItem:barButtonItem animated:YES];
        }
        self.openInController.delegate = self;
    } else {
        self.openInController.delegate = self;
        [self.openInController dismissMenuAnimated:YES];
        self.openInController = nil;
        didOpenFile = YES;
    }
    return didOpenFile;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (void)showDeleteDocumentActionSheet
{

    NSString *title = NSLocalizedString(@"letter view delete document title", @"Delete warning");
    NSString *message = NSLocalizedString(@"letter view delete document message", @"");
    NSString *deleteButtonText = NSLocalizedString(@"letter view delete document ok", @"");
    NSString *cancelButtonText = NSLocalizedString(@"letter view delete document cancel", @"Cancel");

    if(self.attachment.hasValidToPayInvoice){
        if(self.attachment.invoice != nil){
            title = NSLocalizedString(@"invoice delete dialog title", @"Delete invoice");

            if(self.attachment.invoice.timePaid == nil) {
                message = NSLocalizedString(@"invoice delete dialog unpaid message", @"Delete invoice message");
                deleteButtonText = NSLocalizedString(@"invoice delete dialog unpaid delete button", @"Confirme delete invoice");
                cancelButtonText = NSLocalizedString(@"invoice delete dialog unpaid cancel button", @"Cancel delete invoice");
            }else{
                message = NSLocalizedString(@"invoice delete dialog paid message", @"Delete invoice message");
                deleteButtonText = NSLocalizedString(@"invoice delete dialog paid delete button", @"Confirme delete invoice");
                cancelButtonText = NSLocalizedString(@"invoice delete dialog paid cancel button", @"Cancel delete invoice");
            }
        }
    }

    [UIAlertView showWithTitle:title
                       message:message
             cancelButtonTitle:cancelButtonText
             otherButtonTitles:@[deleteButtonText]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            if (self.attachment) {
                                [self deleteDocument];
                            }
                        }
                      }];
}

- (void)showMoveDocumentActionSheet
{
    [self showBlurredActionSheetWithFolders];
}

- (void)showInvoiceSetupAlertIfNoActiveAgreements{

    BOOL userHaveNoActiveAgreements = ![InvoiceBankAgreement hasAnyActiveAgreements];
    BOOL shouldShowInvoiceNotifications = [InvoiceAlertUserDefaults shouldShowInvoiceNotification];
    if (self.attachment.invoice != nil && shouldShowInvoiceNotifications && userHaveNoActiveAgreements){
        [self showInvoiceSetupAlert];
    }
}

-(void)showInvoiceSetupAlert {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"invoice setup alert title", @"")
                                 message:NSLocalizedString(@"invoice setup alert message", @"")
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* chooseBank = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"invoice setup alert action button", @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [GAEvents eventWithCategory:@"faktura-avtale-oppsett-kontekst-basert" action:@"klikk-start-oppsett" label:@"Velg bank" value:nil];
                                     [self didTapChooseBankButton];
                                 }];

    UIAlertAction* later = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"invoice setup alert later button", @"")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [GAEvents eventWithCategory:@"faktura-avtale-oppsett-kontekst-basert" action:@"klikk-start-oppsett" label:@"Senere" value:nil];
                            }];

    UIAlertAction* forget = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"invoice setup alert forget button", @"")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [GAEvents eventWithCategory:@"faktura-avtale-oppsett-kontekst-basert" action:@"klikk-start-oppsett" label:@"Ikke vis meg igjen" value:nil];
                                 [InvoiceAlertUserDefaults dontShowInvoiceNotifications];
                             }];

    [alert addAction:chooseBank];
    [alert addAction:later];
    [alert addAction:forget];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
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

        NSString *paidMessage = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_PAID_MESSAGE", @"Paid message");
        message = [NSString stringWithFormat:paidMessage, self.attachment.invoice.bankName];

        actionButtonTitle = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_GO_TO_BANK_BUTTON_TITLE", @"Go to bank");
        cancelButtonTitle = NSLocalizedString(@"GENERIC_CLOSE_BUTTON_TITLE", @"Close");
    } else if ([self.attachment.invoice.canBePaidByUser boolValue] && [self.attachment.invoice.sendToBankUri length] > 0) {
        title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_SEND_TITLE", @"Send to bank?");

        NSString *bankAccountNumber = self.attachment.document.folder.mailbox.rootResource.currentBankAccount ?: NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_UNKNOWN_BANK_ACCOUNT_NUMBER", @"unknown bank account number");

        NSString *format = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_SEND_MESSAGE", @"Send message");

        NSString *bankLine = [NSString stringWithFormat:@"\%@ \n%@", self.attachment.invoice.bankName, bankAccountNumber];
        message = [NSString stringWithFormat:format, bankLine];

        actionButtonTitle = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_ACTION_BUTTON_SEND_TITLE", @"Send to bank");
        cancelButtonTitle = NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel");

    } else if([InvoiceBankAgreement hasActiveType2Agreement]){
        [self showReadyToPaymentAgreementType2Popup];
        return;
    }else {
        [self showInvoiceSetupAlert];
        return;
    }

    [UIAlertView showWithTitle:title
                       message:message
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:@[ actionButtonTitle ]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex > 0) {
                            if (self.attachment.invoice.timePaid) {
                                NSURL *url = [NSURL URLWithString:self.attachment.invoice.bankHomepage];
                                [[UIApplication sharedApplication] openURL:url]; //Opens external bank website, should be opened in external browser
                            } else if ([self.attachment.invoice.canBePaidByUser boolValue] && [self.attachment.invoice.sendToBankUri length] > 0) {
                                [self sendInvoiceToBank];
                            }
                        }
                      }];
}

-(void)showReadyToPaymentAgreementType2Popup {
    NSString *title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_STATUS_AGREEMENT_TYPE_2_UNPROCESSED_POPUP_TITLE", @"Klar til betaling");
    NSString *message = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_STATUS_AGREEMENT_TYPE_2_UNPROCESSED_POPUP_MESSAGE", @"Klar til betaling hos bank");
    NSString *cancelButtonTitle = NSLocalizedString(@"GENERIC_CLOSE_BUTTON_TITLE", @"Close");

    [UIAlertView showWithTitle: title message: message cancelButtonTitle: cancelButtonTitle otherButtonTitles: nil tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {}];

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
        self.popoverTitleLabel.adjustsFontSizeToFitWidth = YES;
        if (self.attachment) {
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_TITLE", @"From")
                                                                                        description:self.attachment.document.creatorName]];
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_DATE_TITLE", @"Date")
                                                                                        description:[dateFormatter stringFromDate:self.attachment.document.createdAt]]];
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

            if([self.attachment.invoice.kid length] > 0){
            [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_KID", @"KID")
                                                                                        description:[NSString stringWithFormat:@"%@", self.attachment.invoice.kid]]];
            }

            NSString *statusDescriptionText = [self.attachment.invoice statusDescriptionText];
            if (statusDescriptionText) {
                [mutableObjectsInMetadata addObject:[POSLetterPopoverTableViewMobelObject initWithTitle:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_STATUS", @"Status")
                                                                                            description:statusDescriptionText]];
            }
        }

        self.popoverTableView.delegate = self.popoverTableViewDataSourceAndDelegate;
        self.popoverTableView.dataSource = self.popoverTableViewDataSourceAndDelegate;
        self.popoverTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        self.popoverTableViewDataSourceAndDelegate.lineObjects = mutableObjectsInMetadata;
        self.popoverViewHeightConstraint.constant = mutableObjectsInMetadata.count * 48 + 44;
        self.popoverView.layer.cornerRadius = 5.0;

        [UIView animateWithDuration:0.2
                         animations:^{
                           self.shadowView.alpha = 1.0;
                         }];

        [self.navigationController.toolbar setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
        [self.navigationController.toolbar setUserInteractionEnabled:NO];
        [self.popoverTableView reloadData];

        [self.view bringSubviewToFront:self.shadowView];
        [self.view bringSubviewToFront:self.popoverView];

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

    MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view
                                                                          animated:YES];
    [overlayView setTitleLabelText:NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_SENDING_TITLE", @"")];

    [[APIClient sharedClient] sendInvoiceToBank:self.attachment.invoice
        success:^{

          // Now, we've successfully sent the invoice to the bank, but we still need updated document metadata
          // to be able to correctly display the contents of the alertview if the user taps the "sent to bank" button.

            self.sendingInvoice = NO;
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            [self updateCurrentDocument];
        }
        failure:^(APIError *error) {
          [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
          NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
          if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
              if ([[APIClient sharedClient] responseCodeForOAuthIsUnauthorized:response]) {
                  // We were unauthorized, due to the session being invalid.
                  // Let's retry in the next run loop
                  [self performSelector:@selector(sendInvoiceToBank) withObject:nil afterDelay:0.0];

                  return;
              }
          }

          self.sendingInvoice = NO;

          [UIAlertView showWithTitle:error.errorTitle
                             message:[error localizedDescription]
                   cancelButtonTitle:nil
                   otherButtonTitles:@[ error.okButtonTitle ]
                            tapBlock:error.tapBlock];
        }];
}

- (void)updateDocuments
{
    //    if ([POSAPIManager sharedManager].isUpdatingDocuments) {
    //        return;
    //    }


    if (self.attachment.document.folder == nil && self.currentAttachmentURI != nil) {
        self.attachment = [POSAttachment existingAttachmentWithUri:self.currentAttachmentURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    }
    NSString *folderName = self.attachment.document.folder.name;
    NSString *folderUri = self.attachment.document.folder.uri;
    NSString *mailboxDigipostAddress = self.documentsViewController.mailboxDigipostAddress;
    if (mailboxDigipostAddress == nil) {
        mailboxDigipostAddress = self.attachment.document.folder.mailbox.digipostAddress;
    }
    NSString *attachmentUri = self.attachment.uri;
    [[APIClient sharedClient] updateDocumentsInFolderWithName:folderName
        mailboxDigipostAdress:mailboxDigipostAddress
        folderUri:folderUri
        token:[OAuthToken getToken]
        success:^(NSDictionary *responseDictionary) {
          [[POSModelManager sharedManager] updateDocumentsInFolderWithName:folderName
                                                    mailboxDigipostAddress:mailboxDigipostAddress
                                                                attributes:responseDictionary];
          [self updateAttachmentWithAttachmentUri:attachmentUri];
          self.sendingInvoice = NO;
          NSArray *toolbarItems = [self.navigationController.toolbar setupIconsForLetterViewController:self];
          [self setToolbarItems:toolbarItems animated:YES];
          [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
        }
        failure:^(NSError *error) {
          NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
          if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
              //                                                                   if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
              //                                                                       // We were unauthorized, due to the session being invalid.
              //                                                                       // Let's retry in the next run loop
              //                                                                       [self performSelector:@selector(updateDocuments) withObject:nil afterDelay:0.0];
              //
              //                                                                       return;
              //                                                                   }
          }

          [UIAlertView showWithTitle:error.errorTitle
                             message:[error localizedDescription]
                   cancelButtonTitle:nil
                   otherButtonTitles:@[ error.okButtonTitle ]
                            tapBlock:error.tapBlock];
        }];
}

- (void)updateAttachmentWithAttachmentUri:(NSString *)uri
{
    self.attachment = [POSAttachment existingAttachmentWithUri:uri
                                        inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
}

- (void)updateLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem forViewController:(UIViewController *)viewController
{
    leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:YES];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self updateLeftBarButtonForIpad];
    }

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
        [self removeUnlockViewIfPresent];
    }
    self.emptyLetterViewImageView.hidden = !showEmptyView;
    [self setTitle:@""];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (POSBaseEncryptedModel *)currentBaseEncryptModel
{
    if (self.attachment) {
        return self.attachment;
    }
    return nil;
}

- (void)reloadFromMetadata
{
    if (self.attachment.openingReceiptUri) {
        if ([self needsAuthenticationToOpen]) {
            [self showLockedViewCanBeUnlocked:YES];
            return;
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Avsender krever lesekvittering", @"Avsender krever lesekvittering") message: NSLocalizedString(@"Hvis du åpner dette brevet", @"Hvis du åpner dette brevet") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Avbryt", @"Avbryt") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];

        UIAlertAction *sendAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Åpne brevet og send kvittering", @"Åpne brevet og send kvittering") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self shouldValidateOpeningReceipt:self.attachment];
        }];

        [alertController addAction:cancelAction];
        [alertController addAction:sendAction];
        [self presentViewController:alertController animated:YES completion:nil];

    } else {

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (!self.attachment) {
                [self showEmptyView:YES];
                return;
            } else {
                [self showEmptyView:NO];
            }
        }

        if ([self attachmentHasValidFileType] == NO) {
            [self showInvalidFileTypeView];
        }else{
            self.webView.hidden = false;
        }

        [self.navigationController setToolbarHidden:[self shouldHideToolBar:self.attachment] animated:NO];

        [self loadContent];
    }
}


- (void)didTapInformationBarButtonItem:(id)sender
{
    [self setInfoViewVisible:YES];
}

- (void)didTapMoveDocumentBarButtonItem:(id)sender
{
    [self showMoveDocumentActionSheet];
}

- (void)didTapDeleteDocumentBarButtonItem:(id)sender
{
    [self showDeleteDocumentActionSheet];
}

- (void)didTapRenameDocumentBarButtonItem:(id)sender
{
    if ([self needsAuthenticationToOpen]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"cannot rename document need authentication alert title", @"")
                           message:NSLocalizedString(@"cannot rename document need authentication alert message", @"")
                 cancelButtonTitle:NSLocalizedString(@"cannot rename document need authentication alert cancel", @"")
                 otherButtonTitles:@[]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                          }];
    } else {
        [self showRenameAlertView];
    }
}

- (void)didTapOpenDocumentInExternalAppBarButtonItem:(id)sender
{
    BOOL didOpen = [self showOpenInControllerFromBarButtonItem:sender];
    if (didOpen == NO) {
        [UIAlertView showWithTitle:NSLocalizedString(@"open file in external app failed title", @"")
                           message:@""
                 cancelButtonTitle:NSLocalizedString(@"open file in external app OK button", @"")
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                          }];
    }
}

- (void)showOpenInControllerModally
{
    BOOL didOpen = [self showOpenInControllerFromBarButtonItem:nil];
    if (didOpen == NO) {
        [UIAlertView showWithTitle:NSLocalizedString(@"open file in external app failed title", @"")
                           message:@""
                 cancelButtonTitle:NSLocalizedString(@"open file in external app OK button", @"")
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                          }];
    }
}
- (void)didTapMoreOptionsBarButtonItem:(id)sender
{
    AHKActionSheet *actionSheet = [AHKActionSheet setupActionButtonsForLetterController:self];
    [actionSheet show];
    [self setInfoViewVisible:NO];
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

- (void)OAuthViewControllerDidAuthenticate:(SHCOAuthViewController *)OAuthViewController scope:(NSString *)scope
{
    // If a user logs into scope FULL with one fødselsnummer and then uses bankid with another fødselsnummer to auth IDporten, we need to tell the user that.
    NSManagedObjectContext *context = [POSModelManager sharedManager].managedObjectContext;
    POSRootResource *oldRootResource = [POSRootResource existingRootResourceInManagedObjectContext:context];

    NSString *updateURI = self.attachment.document.updateUri;
    OAuthToken *token = [OAuthToken oAuthTokenWithScope:scope];

    [[APIClient sharedClient] updateRootResourceWithScope:scope
        success:^(NSDictionary *responseDict) {
          POSRootResource *newRootResource = [POSRootResource rootResourceWithAttributes:responseDict inManagedObjectContext:context];
          if ([oldRootResource.selfUri isEqualToString:newRootResource.selfUri]) {
              NSString *folderName = self.attachment.document.folder.name;
              NSString *digipostAdress = self.attachment.document.folder.mailbox.digipostAddress;
              NSString *folderURI = self.attachment.document.folder.uri;
              [[POSModelManager sharedManager] updateRootResourceWithAttributes:responseDict];
              [[APIClient sharedClient] updateDocumentsInFolderWithName:folderName
                  mailboxDigipostAdress:digipostAdress
                  folderUri:folderURI
                  token:token
                  success:^(NSDictionary *responseDict) {
                    [[POSModelManager sharedManager] updateDocumentsInFolderWithName:folderName mailboxDigipostAddress:digipostAdress attributes:responseDict];
                    [self removeUnlockViewIfPresent];
                    [self reloadAttachmentWithUpdateURI:updateURI];
                    [self reloadFromMetadata];
                  }
                  failure:^(APIError *error){

                  }];
          } else {
              // Show Alert to user and abort update
              [self showLockedViewCanBeUnlocked:YES];
          }
        }
        failure:^(APIError *error){

        }];
}

- (void)reloadAttachmentWithUpdateURI:(NSString *)updateUri;
{
    POSDocument *document = [POSDocument existingDocumentWithUpdateUri:updateUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    self.attachment = [document mainDocumentAttachment];
}

- (void)didTapChooseBankButton
{
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self performSegueWithIdentifier:kinvoiceOptionsSegue sender:self.attachment];
}

- (void)didTapUnlockButton:(id)sender
{
    [self performSegueWithIdentifier:kaskForhigherAuthenticationLevelSegue sender:self.attachment];
}
@end
