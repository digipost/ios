//
//  SHCLetterViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIAlertView+Blocks.h>
#import <LDProgressView.h>
#import "SHCLetterViewController.h"
#import "SHCAttachment.h"
#import "SHCFileManager.h"
#import "SHCAPIManager.h"
#import "NSString+SHA1String.h"
#import "NSError+ExtraInfo.h"

NSString *const kPushLetterIdentifier = @"PushLetter";
NSString *const kFileTypePDF = @"pdf";
NSString *const kFileTypePNG = @"png";
NSString *const kFileTypeJPG = @"jpg";

@interface SHCLetterViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet LDProgressView *progressView;
@property (strong, nonatomic) NSProgress *progress;

@end

@implementation SHCLetterViewController

#pragma mark - NSObject

- (void)dealloc
{
    [[SHCFileManager sharedFileManager] removeAllDecryptedFiles];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.progressView.color = [UIColor whiteColor];
    self.progressView.flat = @YES;
    self.progressView.showStroke = @YES;
    self.progressView.outerStrokeWidth = @3.0;
    self.progressView.showBackground = @NO;
    self.progressView.progressInset = @6.0;
    self.progressView.progress = 0.0;
    self.progressView.showText = @NO;
    self.progressView.animate = @NO;

    [self setProgressBarFraction:0.0];

    if (![self attachmentHasValidFileType]) {
        [self showInvalidFileTypeView];
    }

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
        [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:NULL];

        [[SHCAPIManager sharedManager] downloadAttachment:self.attachment withProgress:progress success:^{

            if (![[SHCFileManager sharedFileManager] encryptDataForAttachment:self.attachment]) {
                // TODO: maybe display an error message here?
            }

            NSURL *fileURL = [NSURL fileURLWithPath:decryptedFilePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
            [self.webView loadRequest:request];
        } failure:^(NSError *error) {

            [UIAlertView showWithTitle:error.errorTitle
                               message:[error localizedDescription]
                     cancelButtonTitle:nil
                     otherButtonTitles:@[error.okButtonTitle]
                              tapBlock:error.tapBlock];
        }];
    }
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

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
        NSProgress *progress = (NSProgress *)object;

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setProgressBarFraction:progress.fractionCompleted];
        });
    }
}

#pragma mark - Private methods

- (void)setProgressBarFraction:(CGFloat)fraction
{
    CGFloat barRadius = [self.progressView.borderRadius floatValue] - [self.progressView.progressInset floatValue];
    CGFloat barWidth = CGRectGetWidth(self.progressView.frame) - (2 * [self.progressView.progressInset floatValue]);
    CGFloat minimumFraction = (2 * barRadius) / barWidth;

    self.progressView.progress = MAX(minimumFraction, fraction);
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

@end
