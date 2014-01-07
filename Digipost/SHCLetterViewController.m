//
//  SHCLetterViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIAlertView+Blocks.h>
#import <THProgressView.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import "SHCLetterViewController.h"
#import "SHCAttachment.h"
#import "SHCFileManager.h"
#import "SHCAPIManager.h"
#import "NSString+SHA1String.h"
#import "NSError+ExtraInfo.h"

NSString *const kPushLetterIdentifier = @"PushLetter";

@interface SHCLetterViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;
@property (strong, nonatomic) NSProgress *progress;

@end

@implementation SHCLetterViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (![self attachmentHasValidFileType]) {
        [self showInvalidFileTypeView];
        return;
    }

    self.progressView.alpha = 1.0;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadContent];
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
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogError(@"%@", [error localizedDescription]);
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

        [UIView animateWithDuration:0.1 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.alpha = 1.0;
        } completion:nil];

        NSProgress *progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        progress.totalUnitCount = (int64_t)[self.attachment.fileSize integerValue];
        [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(completedUnitCount)) options:NSKeyValueObservingOptionNew context:NULL];

        [[SHCAPIManager sharedManager] downloadAttachment:self.attachment withProgress:progress success:^{

            if (![[SHCFileManager sharedFileManager] encryptDataForAttachment:self.attachment]) {
                // TODO: maybe display an error message here?
            }

            NSURL *fileURL = [NSURL fileURLWithPath:decryptedFilePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
            [self.webView loadRequest:request];
        } failure:^(NSError *error) {

            if ([[error domain] isEqualToString:kAPIManagerErrorDomain] &&
                [error code] == SHCAPIManagerErrorCodeUnauthorized) {

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
    NSLog(@"single tap");
}

- (void)didDoubleTapWebView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"double tap");
}

@end
