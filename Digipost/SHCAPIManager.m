//
//  SHCNetworkClient.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <objc/runtime.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import "SHCAPIManager.h"
#import "SHCOAuthManager.h"
#import "SHCModelManager.h"
#import "SHCFolder.h"
#import "SHCDocument.h"
#import "SHCLoginViewController.h"
#import "NSError+ExtraInfo.h"
#import "SHCAttachment.h"
#import "SHCFileManager.h"
#import "NSString+SHA1String.h"
#import "SHCRootResource.h"
#import "SHCInvoice.h"
#import "SHCReceipt.h"

typedef NS_ENUM(NSInteger, SHCAPIManagerState) {
    SHCAPIManagerStateIdle = 0,
    SHCAPIManagerStateValidatingAccessToken,
    SHCAPIManagerStateValidatingAccessTokenFinished,
    SHCAPIManagerStateRefreshingAccessToken,
    SHCAPIManagerStateRefreshingAccessTokenFinished,
    SHCAPIManagerStateRefreshingAccessTokenFailed,
    SHCAPIManagerStateUpdatingRootResource,
    SHCAPIManagerStateUpdatingRootResourceFinished,
    SHCAPIManagerStateUpdatingRootResourceFailed,
    SHCAPIManagerStateUpdatingDocuments,
    SHCAPIManagerStateUpdatingDocumentsFinished,
    SHCAPIManagerStateUpdatingDocumentsFailed,
    SHCAPIManagerStateDownloadingBaseEncryptionModel,
    SHCAPIManagerStateDownloadingBaseEncryptionModelFinished,
    SHCAPIManagerStateDownloadingBaseEncryptionModelFailed,
    SHCAPIManagerStateMovingDocument,
    SHCAPIManagerStateMovingDocumentFinished,
    SHCAPIManagerStateMovingDocumentFailed,
    SHCAPIManagerStateDeletingDocument,
    SHCAPIManagerStateDeletingDocumentFinished,
    SHCAPIManagerStateDeletingDocumentFailed,
    SHCAPIManagerStateDeletingReceipt,
    SHCAPIManagerStateDeletingReceiptFinished,
    SHCAPIManagerStateDeletingReceiptFailed,
    SHCAPIManagerStateUpdatingBankAccount,
    SHCAPIManagerStateUpdatingBankAccountFinished,
    SHCAPIManagerStateUpdatingBankAccountFailed,
    SHCAPIManagerStateSendingInvoiceToBank,
    SHCAPIManagerStateSendingInvoiceToBankFinished,
    SHCAPIManagerStateSendingInvoiceToBankFailed,
    SHCAPIManagerStateUpdatingReceipts,
    SHCAPIManagerStateUpdatingReceiptsFinished,
    SHCAPIManagerStateUpdatingReceiptsFailed,
    SHCAPIManagerStateUploadingFile,
    SHCAPIManagerStateUploadingFileFinished,
    SHCAPIManagerStateUploadingFileFailed,
    SHCAPIManagerStateLoggingOut,
    SHCAPIManagerStateLoggingOutFailed,
    SHCAPIManagerStateLoggingOutFinished
};

static void *kSHCAPIManagerStateContext = &kSHCAPIManagerStateContext;
static void *kSHCAPIManagerRequestWasSuspended = &kSHCAPIManagerRequestWasSuspended;
static void *kSHCAPIManagerKVOContext = &kSHCAPIManagerKVOContext;

// Custom NSError consts
NSString *const kAPIManagerErrorDomain = @"APIManagerErrorDomain";

// Notification names
NSString *const kAPIManagerUploadProgressStartedNotificationName = @"UploadProgressStartedNotification";
NSString *const kAPIManagerUploadProgressChangedNotificationName = @"UploadProgressChangedNotification";
NSString *const kAPIManagerUploadProgressFinishedNotificationName = @"UploadProgressFinishedNotification";

@interface SHCAPIManager ()

@property (assign, nonatomic) SHCAPIManagerState state;
@property (copy, nonatomic) void(^lastSuccessBlock)(void);
@property (copy, nonatomic) void(^lastFailureBlock)(NSError *);
@property (strong, nonatomic) NSURLResponse *lastURLResponse;
@property (strong, nonatomic) id lastResponseObject;
@property (copy, nonatomic) NSString *lastFolderName;
@property (copy, nonatomic) NSString *lastFolderUri;
@property (strong, nonatomic) NSError *lastError;
@property (strong, nonatomic) SHCDocument *lastDocument;
@property (strong, nonatomic) SHCReceipt *lastReceipt;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) AFHTTPSessionManager *fileTransferSessionManager;
@property (copy, nonatomic) NSString *lastBankAccountUri;
@property (copy, nonatomic) NSString *lastReceiptsUri;
@property (copy, nonatomic) NSString *lastMailboxDigipostAddress;
@property (strong, nonatomic) NSURLSessionDataTask *uploadTask;

@end

@implementation SHCAPIManager

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {

        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

        _state = SHCAPIManagerStateIdle;

        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:NSKeyValueObservingOptionNew context:kSHCAPIManagerStateContext];

        NSURL *baseURL = [NSURL URLWithString:__SERVER_URI__];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;

        NSString *contentType = [NSString stringWithFormat:@"application/vnd.digipost-%@+json", __API_VERSION__];

        // Default session manager
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];

        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sessionManager.requestSerializer setValue:contentType forHTTPHeaderField:@"Accept"];

        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *acceptableContentTypesMutable = [NSMutableSet setWithSet:_sessionManager.responseSerializer.acceptableContentTypes];
        [acceptableContentTypesMutable addObject:contentType];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:acceptableContentTypesMutable];

        // File transfer session manager
        _fileTransferSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];
        _fileTransferSessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _fileTransferSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];

#if (__ACCEPT_SELF_SIGNED_CERTIFICATES__)

        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _fileTransferSessionManager.securityPolicy.allowInvalidCertificates = YES;

#endif
    }

    return self;
}

- (void)dealloc
{
    [self stopLogging];

    @try {
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(state)) context:kSHCAPIManagerStateContext];
    } @catch (NSException *exception) {
        DDLogWarn(@"Caught an exception: %@", exception);
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kSHCAPIManagerStateContext && [keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
        SHCAPIManagerState state = [change[@"new"] integerValue];

        NSString *stateString = nil;
        switch (state) {
            case SHCAPIManagerStateIdle:
                stateString = @"SHCAPIManagerStateIdle";
                break;
            case SHCAPIManagerStateValidatingAccessToken:
                stateString = @"SHCAPIManagerStateValidatingAccessToken";
                break;
            case SHCAPIManagerStateValidatingAccessTokenFinished:
                stateString = @"SHCAPIManagerStateValidatingAccessTokenFinished";
                break;
            case SHCAPIManagerStateRefreshingAccessToken:
                stateString = @"SHCAPIManagerStateRefreshingAccessToken";
                break;
            case SHCAPIManagerStateRefreshingAccessTokenFinished:
                stateString = @"SHCAPIManagerStateRefreshingAccessTokenFinished";
                break;
            case SHCAPIManagerStateRefreshingAccessTokenFailed:
                stateString = @"SHCAPIManagerStateRefreshingAccessTokenFailed";
                break;
            case SHCAPIManagerStateUpdatingRootResource:
                stateString = @"SHCAPIManagerStateUpdatingRootResource";
                break;
            case SHCAPIManagerStateUpdatingRootResourceFinished:
                stateString = @"SHCAPIManagerStateUpdatingRootResourceFinished";
                break;
            case SHCAPIManagerStateUpdatingRootResourceFailed:
                stateString = @"SHCAPIManagerStateUpdatingRootResourceFailed";
                break;
            case SHCAPIManagerStateUpdatingDocuments:
                stateString = @"SHCAPIManagerStateUpdatingDocuments";
                break;
            case SHCAPIManagerStateUpdatingDocumentsFinished:
                stateString = @"SHCAPIManagerStateUpdatingDocumentsFinished";
                break;
            case SHCAPIManagerStateUpdatingDocumentsFailed:
                stateString = @"SHCAPIManagerStateUpdatingDocumentsFailed";
                break;
            case SHCAPIManagerStateDownloadingBaseEncryptionModel:
                stateString = @"SHCAPIManagerStateDownloadingBaseEncryptionModel";
                break;
            case SHCAPIManagerStateDownloadingBaseEncryptionModelFinished:
                stateString = @"SHCAPIManagerStateDownloadingBaseEncryptionModelFinished";
                break;
            case SHCAPIManagerStateDownloadingBaseEncryptionModelFailed:
                stateString = @"SHCAPIManagerStateDownloadingBaseEncryptionModelFailed";
                break;
            case SHCAPIManagerStateMovingDocument:
                stateString = @"SHCAPIManagerStateMovingDocument";
                break;
            case SHCAPIManagerStateMovingDocumentFinished:
                stateString = @"SHCAPIManagerStateMovingDocumentFinished";
                break;
            case SHCAPIManagerStateMovingDocumentFailed:
                stateString = @"SHCAPIManagerStateMovingDocumentFailed";
                break;
            case SHCAPIManagerStateDeletingDocument:
                stateString = @"SHCAPIManagerStateDeletingDocument";
                break;
            case SHCAPIManagerStateDeletingDocumentFinished:
                stateString = @"SHCAPIManagerStateDeletingDocumentFinished";
                break;
            case SHCAPIManagerStateDeletingDocumentFailed:
                stateString = @"SHCAPIManagerStateDeletingDocumentFailed";
                break;
            case SHCAPIManagerStateDeletingReceipt:
                stateString = @"SHCAPIManagerStateDeletingReceipt";
                break;
            case SHCAPIManagerStateDeletingReceiptFinished:
                stateString = @"SHCAPIManagerStateDeletingReceiptFinished";
                break;
            case SHCAPIManagerStateDeletingReceiptFailed:
                stateString = @"SHCAPIManagerStateDeletingReceiptFailed";
                break;
            case SHCAPIManagerStateUpdatingBankAccount:
                stateString = @"SHCAPIManagerStateUpdatingBankAccount";
                break;
            case SHCAPIManagerStateUpdatingBankAccountFinished:
                stateString = @"SHCAPIManagerStateUpdatingBankAccountFinished";
                break;
            case SHCAPIManagerStateUpdatingBankAccountFailed:
                stateString = @"SHCAPIManagerStateUpdatingBankAccountFailed";
                break;
            case SHCAPIManagerStateSendingInvoiceToBank:
                stateString = @"SHCAPIManagerStateSendingInvoiceToBank";
                break;
            case SHCAPIManagerStateSendingInvoiceToBankFinished:
                stateString = @"SHCAPIManagerStateSendingInvoiceToBankFinished";
                break;
            case SHCAPIManagerStateSendingInvoiceToBankFailed:
                stateString = @"SHCAPIManagerStateSendingInvoiceToBankFailed";
                break;
            case SHCAPIManagerStateUpdatingReceipts:
                stateString = @"SHCAPIManagerStateUpdatingReceipts";
                break;
            case SHCAPIManagerStateUpdatingReceiptsFinished:
                stateString = @"SHCAPIManagerStateUpdatingReceiptsFinished";
                break;
            case SHCAPIManagerStateUpdatingReceiptsFailed:
                stateString = @"SHCAPIManagerStateUpdatingReceiptsFailed";
                break;
            case SHCAPIManagerStateUploadingFile:
                stateString = @"SHCAPIManagerStateUploadingFile";
                break;
            case SHCAPIManagerStateUploadingFileFinished:
                stateString = @"SHCAPIManagerStateUploadingFileFinished";
                break;
            case SHCAPIManagerStateUploadingFileFailed:
                stateString = @"SHCAPIManagerStateUploadingFileFailed";
                break;
            case SHCAPIManagerStateLoggingOut:
                stateString = @"SHCAPIManagerStateLoggingOut";
                break;
            case SHCAPIManagerStateLoggingOutFailed:
                stateString = @"SHCAPIManagerStateLoggingOutFailed";
                break;
            case SHCAPIManagerStateLoggingOutFinished:
                stateString = @"SHCAPIManagerStateLoggingOutFinished";
                break;
            default:
                stateString = @"default";
                break;
        }
        
        DDLogInfo(@"state: %@", stateString);

        switch (state) {
            case SHCAPIManagerStateValidatingAccessTokenFinished:
            case SHCAPIManagerStateRefreshingAccessTokenFinished:
            {
                
                if (self.lastSuccessBlock) {
                    [self updateAuthorizationHeader];
                    self.lastSuccessBlock();
                }

                break;
            }
            case SHCAPIManagerStateRefreshingAccessTokenFailed:
            {
                // Check to see if the request failed because the refresh token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse] ||
                    ([self.lastError.domain isEqualToString:kOAuth2ErrorDomain] &&
                     self.lastError.code == SHCOAuthErrorCodeInvalidRefreshTokenResponse)) {
                    // The refresh token was rejected, most likely because the user invalidated
                    // the session in the www.digipost.no web settings interface.

                    [[SHCOAuthManager sharedManager] removeAllTokens];

                    self.lastError.errorTitle = NSLocalizedString(@"GENERIC_REFRESH_TOKEN_INVALID_TITLE", @"Refresh token invalid title");
                    self.lastError.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewControllerNotificationName object:nil];

                        [[SHCOAuthManager sharedManager] removeAllTokens];
                        [[SHCModelManager sharedManager] deleteAllObjects];
                    };

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdatingRootResourceFinished:
            {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    // If the update has been canceled after the network request finished,
                    // but before we have updated the data model, we need to cancel that as well.
                    if (self.updatingRootResource) {
                        [[SHCModelManager sharedManager] updateRootResourceWithAttributes:responseDict];
                    }

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                self.updatingRootResource = NO;

                break;
            }
            case SHCAPIManagerStateUpdatingRootResourceFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingRootResource = NO;

                break;
            }
            case SHCAPIManagerStateUpdatingDocumentsFinished:
            {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    // If the update has been canceled after the network request finished,
                    // but before we have updated the data model, we need to cancel that as well.
                    if (self.updatingDocuments) {
                        [[SHCModelManager sharedManager] updateDocumentsInFolderWithName:self.lastFolderName attributes:responseDict];
                    }

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                self.updatingDocuments = NO;

                break;
            }
            case SHCAPIManagerStateUpdatingDocumentsFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingDocuments = NO;

                break;
            }
            case SHCAPIManagerStateDownloadingBaseEncryptionModelFinished:
            {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                self.downloadingBaseEncryptionModel = NO;

                break;
            }
            case SHCAPIManagerStateDownloadingBaseEncryptionModelFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.downloadingBaseEncryptionModel = NO;

                break;
            }
            case SHCAPIManagerStateMovingDocumentFinished:
            {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    [[SHCModelManager sharedManager] updateDocument:self.lastDocument withAttributes:responseDict];

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateMovingDocumentFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDeletingDocumentFinished:
            {
                [[SHCModelManager sharedManager] deleteDocument:self.lastDocument];

                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDeletingDocumentFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDeletingReceiptFinished:
            {
                [[SHCModelManager sharedManager] deleteReceipt:self.lastReceipt];

                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDeletingReceiptFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdatingBankAccountFinished:
            {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    // If the update has been canceled after the network request finished,
                    // but before we have updated the data model, we need to cancel that as well.
                    if (self.updatingBankAccount) {
                        [[SHCModelManager sharedManager] updateBankAccountWithAttributes:responseDict];
                    }

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                self.updatingBankAccount = NO;
                self.lastBankAccountUri = nil;

                break;
            }
            case SHCAPIManagerStateUpdatingBankAccountFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingBankAccount = NO;
                self.lastBankAccountUri = nil;

                break;
            }
            case SHCAPIManagerStateSendingInvoiceToBankFinished:
            {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateSendingInvoiceToBankFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdatingReceiptsFinished:
            {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    // If the update has been canceled after the network request finished,
                    // but before we have updated the data model, we need to cancel that as well.
                    if (self.updatingReceipts) {
                        [[SHCModelManager sharedManager] updateCardAttributes:responseDict];
                        [[SHCModelManager sharedManager] updateReceiptsInMailboxWithDigipostAddress:self.lastMailboxDigipostAddress attributes:responseDict];
                    }

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                self.updatingReceipts = NO;
                self.lastReceiptsUri = nil;
                self.lastMailboxDigipostAddress = nil;

                break;
            }
            case SHCAPIManagerStateUpdatingReceiptsFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingReceipts = NO;
                self.lastReceiptsUri = nil;
                self.lastMailboxDigipostAddress = nil;

                break;
            }
            case SHCAPIManagerStateUploadingFileFinished:
            {
                [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];

                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                self.uploadingFile = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kAPIManagerUploadProgressFinishedNotificationName object:nil];

                break;
            }
            case SHCAPIManagerStateUploadingFileFailed:
            {
                [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];

                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.uploadingFile = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kAPIManagerUploadProgressFinishedNotificationName object:nil];

                break;
            }
            case SHCAPIManagerStateLoggingOutFinished:
            {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateLoggingOutFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUploadingFile:
            {
                self.uploadingFile = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kAPIManagerUploadProgressStartedNotificationName object:nil];
                break;
            }
            case SHCAPIManagerStateUpdatingRootResource:
            {
                self.updatingRootResource = YES;
                break;
            }
            case SHCAPIManagerStateUpdatingBankAccount:
            {
                self.updatingBankAccount = YES;
                break;
            }
            case SHCAPIManagerStateUpdatingDocuments:
            {
                self.updatingDocuments = YES;
                break;
            }
            case SHCAPIManagerStateDownloadingBaseEncryptionModel:
            {
                self.downloadingBaseEncryptionModel = YES;
                break;
            }
            case SHCAPIManagerStateUpdatingReceipts:
            {
                self.updatingReceipts = YES;
                break;
            }
            case SHCAPIManagerStateValidatingAccessToken:
            case SHCAPIManagerStateRefreshingAccessToken:
            case SHCAPIManagerStateMovingDocument:
            case SHCAPIManagerStateDeletingDocument:
            case SHCAPIManagerStateSendingInvoiceToBank:
            case SHCAPIManagerStateLoggingOut:
            case SHCAPIManagerStateIdle:
            default:
                break;
        }
    } else if (context == kSHCAPIManagerKVOContext && object == self.uploadProgress && [keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAPIManagerUploadProgressChangedNotificationName object:[NSNumber numberWithDouble:self.uploadProgress.fractionCompleted]];
    } else if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Public methods

+ (instancetype)sharedManager
{
    static SHCAPIManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SHCAPIManager alloc] init];
    });

    return sharedInstance;
}

- (void)startLogging
{
    [self stopLogging];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingTaskDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidSuspend:) name:AFNetworkingTaskDidSuspendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidFinishNotification object:nil];
}

- (void)stopLogging
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateRootResourceWithSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateUpdatingRootResource;

    [self validateTokensWithSuccess:^{
        [self.sessionManager GET:__ROOT_RESOURCE_URI__
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastURLResponse = task.response;
                             self.lastResponseObject = responseObject;
                             self.state = SHCAPIManagerStateUpdatingRootResourceFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastURLResponse = task.response;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingRootResourceFailed;
                        }];
    } failure:^(NSError *error) {
        self.updatingRootResource = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingRootResource
{
    NSURL *URL = [NSURL URLWithString:__ROOT_RESOURCE_URI__];
    NSString *pathSuffix = [URL lastPathComponent];
    [self cancelRequestsWithPathSuffix:pathSuffix];

    self.state = SHCAPIManagerStateUpdatingRootResourceFailed;
}

- (void)updateBankAccountWithUri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateUpdatingBankAccount;

    [self validateTokensWithSuccess:^{
        self.lastBankAccountUri = uri;
        [self.sessionManager GET:uri
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastURLResponse = task.response;
                             self.lastResponseObject = responseObject;
                             self.state = SHCAPIManagerStateUpdatingBankAccountFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastURLResponse = task.response;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingBankAccountFailed;
                         }];
    } failure:^(NSError *error) {
        self.updatingBankAccount = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingBankAccount
{
    if (self.lastBankAccountUri) {
        NSURL *URL = [NSURL URLWithString:self.lastBankAccountUri];
        NSString *pathSuffix = [URL lastPathComponent];
        [self cancelRequestsWithPathSuffix:pathSuffix];

        self.lastBankAccountUri = nil;

        self.state = SHCAPIManagerStateUpdatingBankAccountFailed;
    }
}

- (void)sendInvoiceToBank:(SHCInvoice *)invoice withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateSendingInvoiceToBank;

    [self validateTokensWithSuccess:^{

        [self.sessionManager POST:invoice.sendToBankUri
                       parameters:nil
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              self.lastSuccessBlock = success;
                              self.state = SHCAPIManagerStateSendingInvoiceToBankFinished;
                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                              self.lastFailureBlock = failure;
                              self.lastURLResponse = task.response;
                              self.lastError = error;
                              self.state = SHCAPIManagerStateSendingInvoiceToBankFailed;
                          }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateDocumentsInFolderWithName:(NSString *)folderName folderUri:(NSString *)folderUri success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateUpdatingDocuments;

    [self validateTokensWithSuccess:^{
        self.lastFolderUri = folderUri;

        [self.sessionManager GET:folderUri
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastURLResponse = task.response;
                             self.lastResponseObject = responseObject;
                             self.lastFolderName = folderName;
                             self.state = SHCAPIManagerStateUpdatingDocumentsFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastURLResponse = task.response;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingDocumentsFailed;
                         }];
    } failure:^(NSError *error) {
        self.updatingDocuments = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingDocuments
{
    if (self.lastFolderUri) {
        NSURL *URL = [NSURL URLWithString:self.lastFolderUri];
        NSString *pathSuffix = [URL lastPathComponent];
        [self cancelRequestsWithPathSuffix:pathSuffix];

        self.state = SHCAPIManagerStateUpdatingDocumentsFailed;
    }
}

- (void)downloadBaseEncryptionModel:(SHCBaseEncryptedModel *)baseEncryptionModel withProgress:(NSProgress *)progress success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateDownloadingBaseEncryptionModel;

    NSString *baseEncryptionModelUri = baseEncryptionModel.uri;

    [self validateTokensWithSuccess:^{

        NSMutableURLRequest *urlRequest = [self.fileTransferSessionManager.requestSerializer requestWithMethod:@"GET" URLString:baseEncryptionModelUri parameters:nil];

        // Let's set the correct mime type for this file download.
        [urlRequest setValue:[self mimeTypeForFileType:baseEncryptionModel.fileType] forHTTPHeaderField:@"Accept"];

        [self.fileTransferSessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            progress.completedUnitCount = totalBytesWritten;
        }];

        BOOL baseEncryptionModelIsAttachment = [baseEncryptionModel isKindOfClass:[SHCAttachment class]];
        NSURLSessionDownloadTask *task = [self.fileTransferSessionManager downloadTaskWithRequest:urlRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

            // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
            SHCBaseEncryptedModel *changedBaseEncryptionModel = nil;
            if (baseEncryptionModelIsAttachment) {
                changedBaseEncryptionModel = [SHCAttachment existingAttachmentWithUri:baseEncryptionModelUri inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
            } else {
                changedBaseEncryptionModel = [SHCReceipt existingReceiptWithUri:baseEncryptionModelUri inManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
            }

            NSString *filePath = [changedBaseEncryptionModel decryptedFilePath];

            if (!filePath) {
                return nil;
            }

            NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
            return fileUrl;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            BOOL downloadFailure = NO;
            NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
            if ([HTTPURLResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                if ([HTTPURLResponse statusCode] != 200) {
                    downloadFailure = YES;
                }
            }
            if (error || downloadFailure) {

                // If we're getting a 401 from the server, the error object will be nil.
                // Let's set it to something more usable that the caller can interpret.
                if (!error) {
                    error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                                code:SHCAPIManagerErrorCodeUnauthorized
                                            userInfo:nil];
                }

                self.lastURLResponse = response;
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.state = SHCAPIManagerStateDownloadingBaseEncryptionModelFailed;
            } else {
                self.lastURLResponse = response;
                self.lastSuccessBlock = success;
                self.state = SHCAPIManagerStateDownloadingBaseEncryptionModelFinished;
            }
        }];

        [task resume];
    } failure:^(NSError *error) {
        self.downloadingBaseEncryptionModel = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelDownloadingBaseEncryptionModels
{
    NSUInteger counter = 0;

    for (NSURLSessionDownloadTask *downloadTask in self.fileTransferSessionManager.downloadTasks) {
        [downloadTask cancel];
        counter++;
    }

    if (counter > 0) {
        NSString *downloadWord = counter > 1 ? @"downloads" : @"download";
        DDLogInfo(@"%lu %@ canceled", (unsigned long)counter, downloadWord);
    }
}

- (void)moveDocument:(SHCDocument *)document toLocation:(NSString *)location withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateMovingDocument;

    [self validateTokensWithSuccess:^{

        NSString *urlString = document.updateUri;

        AFJSONRequestSerializer *JSONRequestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];

        NSString *contentType = [NSString stringWithFormat:@"application/vnd.digipost-%@+json", __API_VERSION__];
        [JSONRequestSerializer setValue:contentType forHTTPHeaderField:@"Accept"];

        NSString *bearer = [NSString stringWithFormat:@"Bearer %@", [SHCOAuthManager sharedManager].accessToken];
        [JSONRequestSerializer setValue:bearer forHTTPHeaderField:@"Authorization"];

        NSString *subject = [(SHCAttachment *)[document.attachments firstObject] subject];

        NSDictionary *parameters = @{NSStringFromSelector(@selector(subject)): subject,
                                     NSStringFromSelector(@selector(location)): location};

        NSMutableURLRequest *request = [JSONRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:parameters];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

        NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.lastURLResponse = response;
                self.state = SHCAPIManagerStateMovingDocumentFailed;
            } else {
                self.lastSuccessBlock = success;
                self.lastResponseObject = responseObject;
                self.lastDocument = document;
                self.state = SHCAPIManagerStateMovingDocumentFinished;
            }
        }];

        [task resume];

    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteDocument:(SHCDocument *)document withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    NSParameterAssert(document);
    self.state = SHCAPIManagerStateDeletingDocument;

    [self validateTokensWithSuccess:^{

        [self.sessionManager DELETE:document.deleteUri
                         parameters:nil
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                self.lastSuccessBlock = success;
                                self.lastResponseObject = responseObject;
                                self.lastDocument = document;
                                self.state = SHCAPIManagerStateDeletingDocumentFinished;
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                self.lastFailureBlock = failure;
                                self.lastError = error;
                                self.lastURLResponse = task.response;
                                self.state = SHCAPIManagerStateDeletingDocumentFailed;
                            }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)logoutWithSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateLoggingOut;

    [self validateTokensWithSuccess:^{

        SHCRootResource *rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];

        // If we don't have a root resource yet, there's nothing to log out of - let's just return successfully
        if (!rootResource) {
            if (success) {
                success();

                self.state = SHCAPIManagerStateLoggingOutFinished;

                return;
            }
        }

        [self.sessionManager POST:rootResource.logoutUri
                       parameters:nil
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              self.lastSuccessBlock = success;
                              self.state = SHCAPIManagerStateLoggingOutFinished;
                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                              self.lastFailureBlock = failure;
                              self.lastError = error;
                              self.lastURLResponse = task.response;
                              self.state = SHCAPIManagerStateLoggingOutFailed;
                          }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateReceiptsInMailboxWithDigipostAddress:(NSString *)digipostAddress uri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateUpdatingReceipts;

    [self validateTokensWithSuccess:^{
        self.lastReceiptsUri = uri;
        self.lastMailboxDigipostAddress = digipostAddress;

        [self.sessionManager GET:uri
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastURLResponse = task.response;
                             self.lastResponseObject = responseObject;
                             self.state = SHCAPIManagerStateUpdatingReceiptsFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastURLResponse = task.response;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingReceiptsFailed;
                         }];
    } failure:^(NSError *error) {
        self.updatingReceipts = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingReceipts
{
    if (self.lastReceiptsUri) {
        NSURL *URL = [NSURL URLWithString:self.lastReceiptsUri];
        NSString *pathSuffix = [URL lastPathComponent];
        [self cancelRequestsWithPathSuffix:pathSuffix];

        self.state = SHCAPIManagerStateUpdatingReceiptsFailed;
        self.lastMailboxDigipostAddress = nil;
        self.lastReceiptsUri = nil;
    }
}

- (void)deleteReceipt:(SHCReceipt *)receipt withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateDeletingReceipt;

    [self validateTokensWithSuccess:^{

        [self.sessionManager DELETE:receipt.deleteUri
                         parameters:nil
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                self.lastSuccessBlock = success;
                                self.lastResponseObject = responseObject;
                                self.lastReceipt = receipt;
                                self.state = SHCAPIManagerStateDeletingReceiptFinished;
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                self.lastFailureBlock = failure;
                                self.lastError = error;
                                self.lastURLResponse = task.response;
                                self.state = SHCAPIManagerStateDeletingReceiptFailed;
                            }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)uploadFileWithURL:(NSURL *)fileURL success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    // Let's do a couple of checks before kicking off the upload

    // First, check if the file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileURL.path]) {

        NSError *error = [NSError errorWithDomain:kAPIManagerErrorDomain code:SHCAPIManagerErrorCodeUploadFileDoesNotExist userInfo:nil];

        if (failure) {
            failure(error);
        }
        return;
    }

    // Then, check if the file is too big
    unsigned long long maxFileSize = (unsigned long long)(pow(2, 20) * 10); // Max filesize dictated by Digipost (10 MB)

    NSError *error = nil;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fileURL.path error:&error];
    if (error) {
        if (failure) {
            failure(error);
        }
        return;
    }

    unsigned long long fileSize = [fileAttributes fileSize];
    if (fileSize > maxFileSize) {
        NSError *error = [NSError errorWithDomain:kAPIManagerErrorDomain code:SHCAPIManagerErrorCodeUploadFileTooBig userInfo:nil];

        if (failure) {
            failure(error);
        }
        return;
    }

    // The file is good - next, check if we have our upload documents link
    SHCRootResource *rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];
    if (![rootResource.uploadDocumentUri length] > 0) {
        NSError *error = [NSError errorWithDomain:kAPIManagerErrorDomain code:SHCAPIManagerErrorCodeUploadLinkNotFoundInRootResource userInfo:nil];

        if (failure) {
            failure(error);
        }
        return;
    }

    // We're good to go - let's cancel any ongoing uploads and delete any previous temporary files
    if (self.isUploadingFile) {
        [self cancelUploadingFiles];
    }

    [self removeTemporaryUploadFiles];

    // Move the file to our special uploads folder
    NSString *uploadsFolderPath = [[SHCFileManager sharedFileManager] uploadsFolderPath];

    NSString *fileName = [fileURL lastPathComponent];
    NSString *filePath = [uploadsFolderPath stringByAppendingPathComponent:fileName];
    NSURL *uploadURL = [NSURL fileURLWithPath:filePath];

    if (![fileManager moveItemAtURL:fileURL toURL:uploadURL error:&error]) {
        if (failure) {
            failure(error);
        }
        return;
    }

    [self removeTemporaryInboxFiles];

    // Ready!
    self.state = SHCAPIManagerStateUploadingFile;

    [self validateTokensWithSuccess:^{

        NSMutableURLRequest *urlRequest = [self.fileTransferSessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:rootResource.uploadDocumentUri parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            // Subject
            NSRange rangeOfExtension = [fileName rangeOfString:[NSString stringWithFormat:@".%@", [uploadURL pathExtension]]];
            NSString *subject = [fileName substringToIndex:rangeOfExtension.location];
            [formData appendPartWithFormData:[subject dataUsingEncoding:NSASCIIStringEncoding] name:@"subject"];

            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:uploadURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                DDLogError(@"Error reading data: %@", [error localizedDescription]);
            }
            [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"application/pdf"];
        }];

        [urlRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];

        self.uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:@{@"fileName": fileName}];
        self.uploadProgress.totalUnitCount = (int64_t)fileSize;

        [self.uploadProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:kSHCAPIManagerKVOContext];

        __weak typeof(self.uploadProgress) weakUploadProgress = self.uploadProgress;
        [self.fileTransferSessionManager setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            weakUploadProgress.completedUnitCount = totalBytesSent;
        }];

        self.uploadTask = [self.fileTransferSessionManager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {

            BOOL uploadFailure = NO;
            NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
            if ([HTTPURLResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                if ([HTTPURLResponse statusCode] != 200) {
                    uploadFailure = YES;
                }
            }
            if (error || uploadFailure) {

                // In case we're not actually getting an error object, let's create one
                // and set it to something more usable that the caller can interpret.
                if (!error) {
                    error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                                code:SHCAPIManagerErrorCodeUploadFailed
                                            userInfo:nil];
                }

                self.lastURLResponse = response;
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.state = SHCAPIManagerStateUploadingFileFailed;
            } else {
                self.lastURLResponse = response;
                self.lastSuccessBlock = success;
                self.state = SHCAPIManagerStateUploadingFileFinished;
            }
        }];

        [self.uploadTask resume];
    } failure:^(NSError *error) {
        self.uploadingFile = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUploadingFiles
{
    NSUInteger counter = 0;

    for (NSURLSessionUploadTask *uploadTask in self.fileTransferSessionManager.uploadTasks) {
        [uploadTask cancel];
        counter++;
    }

    if (counter > 0) {
        NSString *uploadWord = counter > 1 ? @"uploads" : @"upload";
        DDLogInfo(@"%lu %@ canceled", (unsigned long)counter, uploadWord);
    }
}

- (void)removeTemporaryUploadFiles
{
    NSString *uploadsPath = [[SHCFileManager sharedFileManager] uploadsFolderPath];

    if (![[SHCFileManager sharedFileManager] removeAllFilesInFolder:uploadsPath]) {
        return;
    }
}

- (void)removeTemporaryInboxFiles
{
    NSString *inboxPath = [[SHCFileManager sharedFileManager] inboxFolderPath];

    if (![[SHCFileManager sharedFileManager] removeAllFilesInFolder:inboxPath]) {
        return;
    }
}

- (BOOL)responseCodeIsUnauthorized:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if ([HTTPResponse statusCode] == 401 || // Unauthorized.
            [HTTPResponse statusCode] == 403) { // Forbidden.
            return YES;
        }
    }

    return NO;
}

- (BOOL)responseCodeForOAuthIsUnauthorized:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if ([HTTPResponse statusCode] == 400 || // Bad Request. OAuth 2.0 responds with HTTP 400 if the request is somehow invalid or unauthorized.
            [HTTPResponse statusCode] == 401 || // Unauthorized.
            [HTTPResponse statusCode] == 403) { // Forbidden.
            return YES;
        }
    }

    return NO;
}

#pragma mark - Private methods

- (void)validateTokensWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure
{
    self.state = SHCAPIManagerStateValidatingAccessToken;

    SHCOAuthManager *OAuthManager = [SHCOAuthManager sharedManager];

    // If the OAuth manager already has its access token, we'll go ahead and try an API request using this.
    if (OAuthManager.accessToken) {
        self.lastSuccessBlock = success;
        self.state = SHCAPIManagerStateValidatingAccessTokenFinished;
        return;
    }

    // If the OAuth manager has its refresh token, ask it to update its access token first,
    // and then go ahead and try an API request.
    if (OAuthManager.refreshToken) {
        self.state = SHCAPIManagerStateRefreshingAccessToken;
        [OAuthManager refreshAccessTokenWithRefreshToken:OAuthManager.refreshToken success:^{
            self.lastSuccessBlock = success;
            self.state = SHCAPIManagerStateRefreshingAccessTokenFinished;
        } failure:^(NSError *error) {
            self.lastFailureBlock = failure;
            self.lastError = error;
            self.state = SHCAPIManagerStateRefreshingAccessTokenFailed;
        }];
    }
}

- (void)updateAuthorizationHeader
{
    NSString *bearer = [NSString stringWithFormat:@"Bearer %@", [SHCOAuthManager sharedManager].accessToken];
    [self.sessionManager.requestSerializer setValue:bearer forHTTPHeaderField:@"Authorization"];
    [self.fileTransferSessionManager.requestSerializer setValue:bearer forHTTPHeaderField:@"Authorization"];
}

- (void)networkRequestDidStart:(NSNotification *)notification
{
    NSURLRequest *request = [[notification object] originalRequest];

    if (!request) {
        return;
    }

    BOOL wasSuspended = [objc_getAssociatedObject([notification object], kSHCAPIManagerRequestWasSuspended) boolValue];

    if (!wasSuspended) {
        DDLogInfo(@"%@ %@", [request HTTPMethod], [[request URL] absoluteString]);
    }
}

- (void)networkRequestDidSuspend:(NSNotification *)notification
{
    // Because requests are often put in a suspended state right after they've been started,
    // and then restarted again - we track this fact here, and then only log the requests
    // when they haven't already been suspended.

    objc_setAssociatedObject([notification object], kSHCAPIManagerRequestWasSuspended, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)networkRequestDidFinish:(NSNotification *)notification
{
    NSURLRequest *request = [[notification object] originalRequest];
    NSURLResponse *response = [[notification object] response];
    NSError *error = [[notification object] error];

    NSUInteger responseStatusCode = [(NSHTTPURLResponse *)response statusCode];

    if (error) {
        DDLogDebug(@"[Error] %@ %@ (%ld): %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, error);
    } else {
        DDLogDebug(@"%ld %@", (long)responseStatusCode, [[response URL] absoluteString]);
    }
}

- (void)cleanup
{
    self.lastSuccessBlock = nil;
    self.lastFailureBlock = nil;
    self.lastURLResponse = nil;
    self.lastResponseObject = nil;
    self.lastFolderName = nil;
    self.lastFolderUri = nil;
    self.lastError = nil;
    self.lastDocument = nil;

    self.state = SHCAPIManagerStateIdle;
}

- (void)cancelRequestsWithPathSuffix:(NSString *)pathSuffix
{
    NSUInteger counter = 0;

    for (NSURLSessionDataTask *task in self.sessionManager.tasks) {
        NSString *urlString = [[task.currentRequest URL] absoluteString];
        if ([urlString length] > 0 && [pathSuffix length] > 0 && [urlString hasSuffix:pathSuffix]) {
            [task cancel];
            counter++;
        }
    }

    if (counter > 0) {
        NSString *requestWord = counter > 1 ? @"requests" : @"request";
        DDLogInfo(@"%lu %@ canceled", (unsigned long)counter, requestWord);
    }
}

- (BOOL)requestWasCanceledWithError:(NSError *)error
{
    if ([error code] == -999) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)mimeTypeForFileType:(NSString *)fileType
{
    // First, grab the UTI
    CFStringRef pathExtension = (__bridge_retained CFStringRef)fileType;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);

    // The UTI can be converted to a mime type:
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL) {
        CFRelease(type);
    }

    return mimeType;
}

@end
