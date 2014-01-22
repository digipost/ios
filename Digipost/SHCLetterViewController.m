//
//  SHCLetterViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks.h>
#import <THProgressView.h>
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
#import "SHCReceiptsViewController.h"
#import "SHCInvoice.h"
#import "SHCMailbox.h"
#import "SHCRootResource.h"
#import "SHCModelManager.h"
#import "SHCReceipt.h"

static void *kSHCLetterViewControllerKVOContext = &kSHCLetterViewControllerKVOContext;

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushLetterIdentifier = @"PushLetter";
NSString *const kPushReceiptIdentifier = @"PushReceipt";

// Google Analytics screen name
NSString *const kLetterViewControllerScreenName = @"Letter";

@interface SHCLetterViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UILabel *popoverSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *popoverSenderDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *popoverSenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *popoverDateDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *popoverDateLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (strong, nonatomic) NSProgress *progress;
@property (strong, nonatomic) UIDocumentInteractionController *openInController;
@property (strong, nonatomic) UIBarButtonItem *invoiceBarButtonItem;
@property (assign, nonatomic, getter = isSendingInvoice) BOOL sendingInvoice;

@end

@implementation SHCLetterViewController

#pragma mark - NSObject

- (void)dealloc
{
    @try {
        [self.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(completedUnitCount)) context:kSHCLetterViewControllerKVOContext];
    } @catch (NSException *exception) {
        DDLogDebug(@"Caught an exception: %@", exception);
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.toolbar setBarTintColor:[UIColor colorWithRed:64.0/255.0 green:66.0/255.0 blue:69.0/255.0 alpha:0.95]];

    UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar-icon-info"]
                                                            landscapeImagePhone:[UIImage imageNamed:@"navbar-icon-info"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(didTapInfo:)];

    UIBarButtonItem *actionBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar-icon-action"]
                                                              landscapeImagePhone:[UIImage imageNamed:@"navbar-icon-action"]
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(didTapAction:)];

    self.navigationItem.rightBarButtonItems = @[actionBarButtonItem, infoBarButtonItem];

    self.screenName = kLetterViewControllerScreenName;

    self.popoverSenderDescriptionLabel.text = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_SENDER_TITLE", @"From");
    self.popoverDateDescriptionLabel.text = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_POPOVER_DATE_TITLE", @"Date");

    if (self.attachment.invoice) {
        [self updateToolbarItemsWithInvoice];
    }

    self.moveBarButtonItem.title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_MOVE_BUTTON_TITLE", @"Move");
    self.deleteBarButtonItem.title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_DELETE_BUTTON_TITLE", @"Delete");

    if (![self attachmentHasValidFileType]) {
        [self showInvalidFileTypeView];
        return;
    }

    self.progressView.borderTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor whiteColor];

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

    [self loadContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:NO animated:NO];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Force a redraw of the progress bar
    self.progressView.progress = self.progressView.progress;

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.progressView.alpha = 0.0;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.progressView.alpha = 0.0;

    DDLogError(@"%@", [error localizedDescription]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL isFileURL]) {
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
    return NO;
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    self.openInController = nil;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kSHCLetterViewControllerKVOContext && object == self.progress && [keyPath isEqualToString:NSStringFromSelector(@selector(completedUnitCount))]) {
        NSProgress *progress = (NSProgress *)object;

        dispatch_sync(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress.fractionCompleted;
        });
    } else if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - IBActions

- (IBAction)didTapMove:(UIBarButtonItem *)sender
{
    NSMutableArray *destinations = [NSMutableArray array];
    if (![[self.attachment.document.location lowercaseString] isEqualToString:[kFolderInboxName lowercaseString]]) {
        [destinations addObject:kFolderInboxName];
    }
    if (![[self.attachment.document.location lowercaseString] isEqualToString:[kFolderWorkAreaName lowercaseString]]) {
        [destinations addObject:kFolderWorkAreaName];
    }
    if (![[self.attachment.document.location lowercaseString] isEqualToString:[kFolderArchiveName lowercaseString]]) {
        [destinations addObject:kFolderArchiveName];
    }

    [UIActionSheet showFromToolbar:self.navigationController.toolbar
                         withTitle:nil
                 cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
            destructiveButtonTitle:nil
                 otherButtonTitles:destinations
                          tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                              if (buttonIndex < [destinations count]) {
                                  NSString *location = [destinations[buttonIndex] uppercaseString];

                                  [self moveDocumentToLocation:location];
                              }
                          }];
}

- (IBAction)didTapDelete:(UIBarButtonItem *)sender
{
    [UIActionSheet showFromToolbar:self.navigationController.toolbar
                         withTitle:nil
                 cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
            destructiveButtonTitle:NSLocalizedString(@"GENERIC_DELETE_BUTTON_TITLE", @"Delete")
                 otherButtonTitles:nil
                          tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                              if (buttonIndex == 0) {
                                  [self deleteDocument];
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
    } else {
        [self loadContentFromWebWithBaseEncryptionModel:baseEncryptionModel];
    }
}

- (void)loadContentFromWebWithBaseEncryptionModel:(SHCBaseEncryptedModel *)baseEncryptionModel
{
    NSProgress *progress = nil;

    if ([baseEncryptionModel isKindOfClass:[SHCAttachment class]]) {
        [UIView animateWithDuration:0.3 delay:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.alpha = 1.0;
        } completion:nil];

        progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        progress.totalUnitCount = (int64_t)[self.attachment.fileSize integerValue];

        [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(completedUnitCount)) options:NSKeyValueObservingOptionNew context:kSHCLetterViewControllerKVOContext];

        self.progress = progress;
    }

    [[SHCAPIManager sharedManager] downloadBaseEncryptionModel:baseEncryptionModel withProgress:progress success:^{

        NSError *error = nil;
        if (![[SHCFileManager sharedFileManager] encryptDataForBaseEncryptionModel:baseEncryptionModel error:&error]) {
            [UIAlertView showWithTitle:error.errorTitle
                               message:[error localizedDescription]
                     cancelButtonTitle:nil
                     otherButtonTitles:@[error.okButtonTitle]
                              tapBlock:error.tapBlock];
        }

        NSURL *fileURL = [NSURL fileURLWithPath:[baseEncryptionModel decryptedFilePath]];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [self.webView loadRequest:request];
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
            // We were unauthorized, due to the session being invalid.
            // Let's retry in the next run loop
            [self performSelector:@selector(loadContentFromWebWithBaseEncryptionModel:) withObject:baseEncryptionModel afterDelay:0.0];

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
    NSArray *validFilesTypes = @[@"pdf", @"png", @"jpg", @"jpeg", @"gif", @"docx", @"xlsx", @"pptx", @"txt", @"html", @"numbers", @"key", @"pages"];

    return [validFilesTypes containsObject:self.attachment.fileType];
}

- (void)showInvalidFileTypeView
{
    self.errorLabel.text = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVALID_FILE_TYPE_MESSAGE", @"Invalid file type message");

    [UIView animateWithDuration:0.3 animations:^{
        self.errorLabel.alpha = 1.0;
    }];
}

- (void)didSingleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    BOOL barsHidden = self.navigationController.isNavigationBarHidden;

    [self.navigationController setNavigationBarHidden:!barsHidden animated:YES];

    [self.navigationController setToolbarHidden:!barsHidden animated:YES];
}

- (void)didDoubleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"double tap");
}

- (void)moveDocumentToLocation:(NSString *)location
{
    [[SHCAPIManager sharedManager] moveDocument:self.attachment.document toLocation:location withSuccess:^{

        if (self.documentsViewController) {
            self.documentsViewController.needsReload = YES;

            // Becuase we might have been pushed from the attachments vc, make sure that we pop
            // all the way back to the documents vc.
            [self.navigationController popToViewController:self.documentsViewController animated:YES];
        } else if (self.receiptsViewController) {
            self.receiptsViewController.needsReload = YES;

            [self.navigationController popViewControllerAnimated:YES];
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
    [[SHCAPIManager sharedManager] deleteDocument:self.attachment.document withSuccess:^{

        if (self.documentsViewController) {
            self.documentsViewController.needsReload = YES;

            // Becuase we might have been pushed from the attachments vc, make sure that we pop
            // all the way back to the documents vc.
            [self.navigationController popToViewController:self.documentsViewController animated:YES];
        } else if (self.receiptsViewController) {
            self.receiptsViewController.needsReload = YES;

            [self.navigationController popViewControllerAnimated:YES];
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

        self.popoverSubjectLabel.text = self.attachment.subject;
        self.popoverSenderLabel.text = self.attachment.document.creatorName;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;

        self.popoverDateLabel.text = [dateFormatter stringFromDate:self.attachment.document.createdAt];

        [UIView animateWithDuration:0.2 animations:^{
            self.shadowView.alpha = 1.0;
        }];

        [self.navigationController.toolbar setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
        [self.navigationController.toolbar setUserInteractionEnabled:NO];

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
    [self updateToolbarItemsWithInvoice];

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
        [self updateToolbarItemsWithInvoice];

        [UIAlertView showWithTitle:error.errorTitle
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[error.okButtonTitle]
                          tapBlock:error.tapBlock];
    }];
}

- (void)updateDocuments
{
    NSString *attachmentUri = self.attachment.uri;

    [[SHCAPIManager sharedManager] updateDocumentsInFolderWithName:self.attachment.document.folder.name folderUri:self.attachment.document.folder.uri success:^{
        [self updateAttachmentWithAttachmentUri:attachmentUri];
        self.sendingInvoice = NO;
        [self updateToolbarItemsWithInvoice];
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

- (void)updateToolbarItemsWithInvoice
{
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

    UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.toolbarItems = @[self.invoiceBarButtonItem, flexibleSpaceBarButtonItem, self.moveBarButtonItem, flexibleSpaceBarButtonItem, self.deleteBarButtonItem];
}

@end
