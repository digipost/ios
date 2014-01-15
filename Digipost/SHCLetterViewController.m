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

static void *kSHCLetterViewControllerKVOContext = &kSHCLetterViewControllerKVOContext;

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushLetterIdentifier = @"PushLetter";

// Google Analytics screen name
NSString *const kLetterViewControllerScreenName = @"Letter";

@interface SHCLetterViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (strong, nonatomic) NSProgress *progress;

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

    if (![self attachmentHasValidFileType]) {
        [self showInvalidFileTypeView];
        return;
    }

    self.moveBarButtonItem.title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_MOVE_BUTTON_TITLE", @"Move");
    self.deleteBarButtonItem.title = NSLocalizedString(@"LETTER_VIEW_CONTROLLER_DELETE_BUTTON_TITLE", @"Delete");

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
    DDLogError(@"%@", [error localizedDescription]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL isFileURL]) {
        return YES;
    } else {
        [[UIApplication sharedApplication] openURL:request.URL];

        return NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kSHCLetterViewControllerKVOContext && [keyPath isEqualToString:NSStringFromSelector(@selector(completedUnitCount))]) {
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

#pragma mark - Private methods

- (void)loadContent
{
    NSString *encryptedFilePath = [self.attachment encryptedFilePath];
    NSString *decryptedFilePath = [self.attachment decryptedFilePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        NSError *error = nil;
        if (![[SHCFileManager sharedFileManager] decryptDataForAttachment:self.attachment error:&error]) {
            [UIAlertView showWithTitle:error.errorTitle
                               message:[error localizedDescription]
                     cancelButtonTitle:nil
                     otherButtonTitles:@[error.okButtonTitle]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
            return;
        }

        NSURL *fileURL = [NSURL fileURLWithPath:decryptedFilePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [self.webView loadRequest:request];
    } else {

        [UIView animateWithDuration:0.3 delay:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.alpha = 1.0;
        } completion:nil];

        self.progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.progress.totalUnitCount = (int64_t)[self.attachment.fileSize integerValue];

        [self.progress addObserver:self forKeyPath:NSStringFromSelector(@selector(completedUnitCount)) options:NSKeyValueObservingOptionNew context:kSHCLetterViewControllerKVOContext];

        [[SHCAPIManager sharedManager] downloadAttachment:self.attachment withProgress:self.progress success:^{

            NSError *error = nil;
            if (![[SHCFileManager sharedFileManager] encryptDataForAttachment:self.attachment error:&error]) {
                [UIAlertView showWithTitle:error.errorTitle
                                   message:[error localizedDescription]
                         cancelButtonTitle:nil
                         otherButtonTitles:@[error.okButtonTitle]
                                  tapBlock:error.tapBlock];
            }

            NSURL *fileURL = [NSURL fileURLWithPath:decryptedFilePath];
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
                [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];

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
    [[SHCAPIManager sharedManager] cancelDownloadingAttachments];
    [[SHCFileManager sharedFileManager] removeAllDecryptedFiles];
}

- (BOOL)attachmentHasValidFileType
{
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
    [[SHCAPIManager sharedManager] moveDocument:self.attachment.document toLocation:location success:^{

        self.documentsViewController.needsReload = YES;

        // Becuase we might have been pushed from the attachments vc, make sure that we pop
        // all the way back to the documents vc.
        [self.navigationController popToViewController:self.documentsViewController animated:YES];
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
    [[SHCAPIManager sharedManager] deleteDocument:self.attachment.document success:^{

        self.documentsViewController.needsReload = YES;

        // Becuase we might have been pushed from the attachments vc, make sure that we pop
        // all the way back to the documents vc.
        [self.navigationController popToViewController:self.documentsViewController animated:YES];
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
}

- (void)didTapAction:(UIBarButtonItem *)barButtonItem
{
}

@end
