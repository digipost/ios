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

typedef NS_ENUM( NSInteger, SHCAPIManagerState ) {
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
    SHCAPIManagerStateDownloadingAttachment,
    SHCAPIManagerStateDownloadingAttachmentFinished,
    SHCAPIManagerStateDownloadingAttachmentFailed,
    SHCAPIManagerStateMovingDocument,
    SHCAPIManagerStateMovingDocumentFinished,
    SHCAPIManagerStateMovingDocumentFailed,
    SHCAPIManagerStateDeletingDocument,
    SHCAPIManagerStateDeletingDocumentFinished,
    SHCAPIManagerStateDeletingDocumentFailed,
    SHCAPIManagerStateUpdatingBankAccount,
    SHCAPIManagerStateUpdatingBankAccountFinished,
    SHCAPIManagerStateUpdatingBankAccountFailed,
    SHCAPIManagerStateSendingInvoiceToBank,
    SHCAPIManagerStateSendingInvoiceToBankFinished,
    SHCAPIManagerStateSendingInvoiceToBankFailed,
    SHCAPIManagerStateUpdatingReceipts,
    SHCAPIManagerStateUpdatingReceiptsFinished,
    SHCAPIManagerStateUpdatingReceiptsFailed,
    SHCAPIManagerStateLoggingOut,
    SHCAPIManagerStateLoggingOutFailed,
    SHCAPIManagerStateLoggingOutFinished
};

static void *kSHCAPIManagerStateContext = &kSHCAPIManagerStateContext;
static void *kSHCAPIManagerRequestWasSuspended = &kSHCAPIManagerRequestWasSuspended;

// Custom NSError consts
NSString *const kAPIManagerErrorDomain = @"APIManagerErrorDomain";

@interface SHCAPIManager ()

@property (assign, nonatomic) SHCAPIManagerState state;
@property (copy, nonatomic) void(^lastSuccessBlock)(void);
@property (copy, nonatomic) void(^lastFailureBlock)(NSError *);
@property (strong, nonatomic) NSURLResponse *lastURLResponse;
@property (strong, nonatomic) id lastResponseObject;
@property (copy, nonatomic) NSString *lastFolderName;
@property (copy, nonatomic) NSString *lastFolderUri;
@property (strong, nonatomic) NSError *lastError;
@property (strong, nonatomic) SHCAttachment *lastAttachment;
@property (strong, nonatomic) NSProgress *lastProgress;
@property (strong, nonatomic) SHCDocument *lastDocument;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (copy, nonatomic) NSString *lastBankAccountUri;
@property (copy, nonatomic) NSString *lastReceiptsUri;
@property (copy, nonatomic) NSString *lastMailboxDigipostAddress;

- (void)cancelRequestsWithPath:(NSString *)path;

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

        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                                   sessionConfiguration:configuration];

        NSString *contentType = [NSString stringWithFormat:@"application/vnd.digipost-%@+json", __API_VERSION__];

        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sessionManager.requestSerializer setValue:contentType forHTTPHeaderField:@"Accept"];

        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *acceptableContentTypesMutable = [NSMutableSet setWithSet:_sessionManager.responseSerializer.acceptableContentTypes];
        [acceptableContentTypesMutable addObject:contentType];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:acceptableContentTypesMutable];

#if (__ACCEPT_SELF_SIGNED_CERTIFICATES__)

        _sessionManager.securityPolicy.allowInvalidCertificates = YES;

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
            case SHCAPIManagerStateDownloadingAttachment:
                stateString = @"SHCAPIManagerStateDownloadingAttachment";
                break;
            case SHCAPIManagerStateDownloadingAttachmentFinished:
                stateString = @"SHCAPIManagerStateDownloadingAttachmentFinished";
                break;
            case SHCAPIManagerStateDownloadingAttachmentFailed:
                stateString = @"SHCAPIManagerStateDownloadingAttachmentFailed";
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
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPopToLoginViewControllerNotificationName object:nil];
                    };

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCancelledWithError:self.lastError]) {
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

                    [[SHCModelManager sharedManager] updateRootResourceWithAttributes:responseDict];

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
                } else if (![self requestWasCancelledWithError:self.lastError]) {
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

                    [[SHCModelManager sharedManager] updateDocumentsInFolderWithName:self.lastFolderName attributes:responseDict];

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
                } else if (![self requestWasCancelledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingDocuments = NO;

                break;
            }
            case SHCAPIManagerStateDownloadingAttachmentFinished:
            {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDownloadingAttachmentFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCancelledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

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
                } else if (![self requestWasCancelledWithError:self.lastError]) {
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
                } else if (![self requestWasCancelledWithError:self.lastError]) {
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

                    [[SHCModelManager sharedManager] updateBankAccountWithAttributes:responseDict];

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

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
                } else if (![self requestWasCancelledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

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
                } else if (![self requestWasCancelledWithError:self.lastError]) {
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

                    [[SHCModelManager sharedManager] updateReceiptsInMailboxWithDigipostAddress:self.lastMailboxDigipostAddress attributes:responseDict];

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                self.updatingReceipts = NO;

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
                } else if (![self requestWasCancelledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingReceipts = NO;

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
                } else if (![self requestWasCancelledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdatingRootResource:
            case SHCAPIManagerStateUpdatingDocuments:
            case SHCAPIManagerStateValidatingAccessToken:
            case SHCAPIManagerStateRefreshingAccessToken:
            case SHCAPIManagerStateDownloadingAttachment:
            case SHCAPIManagerStateMovingDocument:
            case SHCAPIManagerStateDeletingDocument:
            case SHCAPIManagerStateUpdatingBankAccount:
            case SHCAPIManagerStateSendingInvoiceToBank:
            case SHCAPIManagerStateUpdatingReceipts:
            case SHCAPIManagerStateLoggingOut:
            case SHCAPIManagerStateIdle:
            default:
                break;
        }
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
    self.updatingRootResource = YES;

    [self validateTokensWithSuccess:^{
        self.state = SHCAPIManagerStateUpdatingRootResource;
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
    [self cancelRequestsWithPath:__ROOT_RESOURCE_URI__];
}

- (void)updateBankAccountWithUri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    [self validateTokensWithSuccess:^{
        self.lastBankAccountUri = uri;
        self.state = SHCAPIManagerStateUpdatingBankAccount;
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
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingBankAccount
{
    if (self.lastBankAccountUri) {
        NSURL *URL = [NSURL URLWithString:self.lastBankAccountUri];
        NSString *pathSuffix = [[URL pathComponents] lastObject];
        [self cancelRequestsWithPath:pathSuffix];
    }
}

- (void)sendInvoiceToBank:(SHCInvoice *)invoice withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    [self validateTokensWithSuccess:^{
        self.state = SHCAPIManagerStateSendingInvoiceToBank;

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
    self.updatingDocuments = YES;

    [self validateTokensWithSuccess:^{
        self.lastFolderUri = folderUri;

        self.state = SHCAPIManagerStateUpdatingDocuments;

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
        NSString *pathSuffix = [[URL pathComponents] lastObject];
        [self cancelRequestsWithPath:pathSuffix];
    }
}

- (void)downloadAttachment:(SHCAttachment *)attachment withProgress:(NSProgress *)progress success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    [self validateTokensWithSuccess:^{
        self.state = SHCAPIManagerStateDownloadingAttachment;

        NSString *urlString = [[NSURL URLWithString:attachment.uri relativeToURL:self.sessionManager.baseURL] absoluteString];

        NSMutableURLRequest *urlRequest = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:nil];

        [self.sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            progress.completedUnitCount = totalBytesWritten;
        }];

        NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:urlRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSString *filePath = [attachment decryptedFilePath];
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
                // Let's set it to something more usable that the calling instance can interpret.
                if (!error) {
                    error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                                code:SHCAPIManagerErrorCodeUnauthorized
                                            userInfo:nil];
                }

                self.lastURLResponse = response;
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.lastAttachment = attachment;
                self.lastProgress = progress;
                self.state = SHCAPIManagerStateDownloadingAttachmentFailed;
            } else {
                self.lastURLResponse = response;
                self.lastSuccessBlock = success;
                self.state = SHCAPIManagerStateDownloadingAttachmentFinished;
            }
        }];

        [task resume];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)moveDocument:(SHCDocument *)document toLocation:(NSString *)location withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    [self validateTokensWithSuccess:^{
        self.state = SHCAPIManagerStateMovingDocument;

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
    [self validateTokensWithSuccess:^{
        self.state = SHCAPIManagerStateDeletingDocument;

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
    [self validateTokensWithSuccess:^{
        self.state = SHCAPIManagerStateLoggingOut;

        SHCRootResource *rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:[SHCModelManager sharedManager].managedObjectContext];

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

- (void)cancelDownloadingAttachments
{
    for (NSURLSessionDownloadTask *downloadTask in self.sessionManager.downloadTasks) {
        [downloadTask cancel];
    }
}

- (void)updateReceiptsInMailboxWithDigipostAddress:(NSString *)digipostAddress uri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.updatingReceipts = YES;

    [self validateTokensWithSuccess:^{
        self.lastReceiptsUri = uri;
        self.lastMailboxDigipostAddress = digipostAddress;

        self.state = SHCAPIManagerStateUpdatingReceipts;

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
        NSString *pathSuffix = [[URL pathComponents] lastObject];
        [self cancelRequestsWithPath:pathSuffix];
    }
}

- (void)deleteReceipt:(SHCReceipt *)receipt withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
}

- (BOOL)responseCodeIsUnauthorized:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if ([HTTPResponse statusCode] == 401) { // Unauthorized.
            return YES;
        }
    }

    return NO;
}

- (BOOL)responseCodeForOAuthIsUnauthorized:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if ([HTTPResponse statusCode] == 400 || // Bad Request. OAuth 2.0 responds with HTTP 400 if the request is somehow invalid or unauthorized
            [HTTPResponse statusCode] == 401) { // Unauthorized.
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
    self.lastAttachment = nil;
    self.lastProgress = nil;
    self.lastDocument = nil;
    self.lastBankAccountUri = nil;
    self.lastReceiptsUri = nil;
    self.lastMailboxDigipostAddress = nil;

    self.state = SHCAPIManagerStateIdle;
}

- (void)cancelRequestsWithPath:(NSString *)path
{
    NSUInteger counter = 0;

    for (NSURLSessionDataTask *task in self.sessionManager.tasks) {
        NSString *urlString = [[task.currentRequest URL] absoluteString];
        if ([urlString length] > 0 && [path length] > 0 && [urlString hasSuffix:path]) {
            [task cancel];
            counter++;
        }
    }

    if (counter > 0) {
        DDLogInfo(@"%lu requests cancelled", (unsigned long)counter);
    }
}

- (BOOL)requestWasCancelledWithError:(NSError *)error
{
    if ([error code] == -999) {
        return YES;
    } else {
        return NO;
    }
}

@end
