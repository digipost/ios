//
//  SHCLetterViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCLetterViewController.h"
#import "SHCAttachment.h"
#import "SHCFileManager.h"
#import "SHCAPIManager.h"
#import "NSString+SHA1String.h"
#import <LDProgressView.h>

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

    NSData *decryptedFileData = [[SHCFileManager sharedFileManager] decryptedDataForAttachment:self.attachment];

    NSString *MIMEType = nil;
    if ([self.attachment.fileType isEqualToString:kFileTypePDF]) {
        MIMEType = @"application/pdf";
    } else if ([self.attachment.fileType isEqualToString:kFileTypePNG]) {
        MIMEType = @"image/png";
    } else if ([self.attachment.fileType isEqualToString:kFileTypeJPG]) {
        MIMEType = @"image/jpg";
    }

    if (decryptedFileData) {
        [self.webView loadData:decryptedFileData MIMEType:MIMEType textEncodingName:@"utf-8" baseURL:nil];
    } else {

        [UIView animateWithDuration:0.1 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.alpha = 1.0;
        } completion:nil];

        NSProgress *progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        progress.totalUnitCount = (int64_t)[self.attachment.fileSize integerValue];
        [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:NULL];

        [[SHCAPIManager sharedManager] downloadAttachment:self.attachment withProgress:progress success:^{

            NSData *freshFileData = [NSData dataWithContentsOfFile:[self.attachment decryptedFilePath]];

            [[SHCFileManager sharedFileManager] encryptDataForAttachment:self.attachment];

            [self.webView loadData:freshFileData MIMEType:MIMEType textEncodingName:@"utf-8" baseURL:nil];
        } failure:^(NSError *error) {

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

@end
