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
#import "UIViewController+PreviousViewController.h"
#import "UIViewController+NeedsReload.h"

NSString *const kPushLetterIdentifier = @"PushLetter";

@interface SHCLetterViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarToBottomGuideConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (strong, nonatomic) NSProgress *progress;
@property (assign, nonatomic, getter = isContentLoaded) BOOL contentLoaded;

@end

@implementation SHCLetterViewController

#pragma mark - NSObject

- (void)dealloc
{
    if (self.isContentLoaded) {
        self.contentLoaded = NO;

        [self unloadContent];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (![self attachmentHasValidFileType]) {
        [self showInvalidFileTypeView];
        return;
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        self.toolbarHeightConstraint.constant = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44.0 : 32.0;
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

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.isContentLoaded) {
        self.contentLoaded = NO;

        [self unloadContent];
    }

    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        self.toolbarHeightConstraint.constant = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 44.0 : 32.0;
    }
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
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(completedUnitCount))]) {
        NSProgress *progress = (NSProgress *)object;

        dispatch_sync(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress.fractionCompleted;
        });
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

    [UIActionSheet showFromToolbar:self.toolbar
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
    [UIActionSheet showFromToolbar:self.toolbar
                         withTitle:nil
                 cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
            destructiveButtonTitle:NSLocalizedString(@"GENERIC_DELETE_BUTTON_TITLE", @"Delete")
                 otherButtonTitles:nil
                          tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                              [self deleteDocument];
                          }];
}

#pragma mark - Private methods

- (void)loadContent
{
    NSString *encryptedFilePath = [self.attachment encryptedFilePath];
    NSString *decryptedFilePath = [self.attachment decryptedFilePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        if (![[SHCFileManager sharedFileManager] decryptDataForAttachment:self.attachment]) {
            // TODO: throw an error message to the user here
            return;
        }

        NSURL *fileURL = [NSURL fileURLWithPath:decryptedFilePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [self.webView loadRequest:request];
    } else {

        self.progressView.alpha = 1.0;

        [UIView animateWithDuration:0.1 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.alpha = 1.0;
        } completion:nil];

        NSProgress *progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        progress.totalUnitCount = (int64_t)[self.attachment.fileSize integerValue];
        [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(completedUnitCount)) options:NSKeyValueObservingOptionNew context:NULL];
        self.contentLoaded = YES;

        [[SHCAPIManager sharedManager] downloadAttachment:self.attachment withProgress:progress success:^{

            if (![[SHCFileManager sharedFileManager] encryptDataForAttachment:self.attachment]) {
                // TODO: maybe display an error message here?
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
                    if ([[SHCAPIManager sharedManager] responseCodeIsIn400Range:response]) {
                        unauthorized = YES;
                    }
                }
            }

            if (unauthorized) {
                // We were unauthorized, due to the session being invalid.
                // Let's retry in the next run loop
                double delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self loadContent];
                });
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
    @try {
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(completedUnitCount)) context:NULL];
    } @catch (NSException *exception) {
        DDLogDebug(@"Caught an exception: %@", exception);
    }

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
    // TODO: implement this.
}

- (void)didSingleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    BOOL barsHidden = self.navigationController.isNavigationBarHidden;

    [self.navigationController setNavigationBarHidden:!barsHidden animated:YES];

    self.toolbarToBottomGuideConstraint.constant = barsHidden ? 0.0 : -44.0;
}

- (void)didDoubleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"double tap");
}

- (void)moveDocumentToLocation:(NSString *)location
{
    [[SHCAPIManager sharedManager] moveDocument:self.attachment.document toLocation:location success:^{

        self.previousViewController.needsReload = YES;

        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {

        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsIn400Range:response]) {
                // We were unauthorized, due to the session being invalid.
                // Let's retry in the next run loop
                double delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self moveDocumentToLocation:location];
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

- (void)deleteDocument
{
    [[SHCAPIManager sharedManager] deleteDocument:self.attachment.document success:^{

        self.previousViewController.needsReload = YES;

        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {

        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if ([[SHCAPIManager sharedManager] responseCodeIsIn400Range:response]) {
                // We were unauthorized, due to the session being invalid.
                // Let's retry in the next run loop
                double delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self deleteDocument];
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

@end
