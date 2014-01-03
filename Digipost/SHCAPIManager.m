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
#import "SHCAPIManager.h"
#import "SHCOAuthManager.h"
#import "SHCModelManager.h"
#import "SHCFolder.h"
#import "SHCLoginViewController.h"
#import "NSError+ExtraInfo.h"
#import "SHCAttachment.h"
#import "SHCFileManager.h"
#import "NSString+SHA1String.h"

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
    SHCAPIManagerStateDownloadingAttachmentFailed
};

static void *kSHCAPIManagerStateContext = &kSHCAPIManagerStateContext;
static void *kSHCAPIManagerRequestWasSuspended = &kSHCAPIManagerRequestWasSuspended;

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
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

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

                break;
            }
            case SHCAPIManagerStateUpdatingRootResourceFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsIn400Range:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    // And recursively call the update to force a renewal of the access token
                    [self updateRootResourceWithSuccess:^{
                        if (self.lastSuccessBlock) {
                            self.lastSuccessBlock();
                        }
                    } failure:^(NSError *error) {
                        if (self.lastFailureBlock) {
                            self.lastFailureBlock(self.lastError);
                        }
                    }];
                } else if (![self requestWasCancelledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdatingDocumentsFinished:
            {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    [[SHCModelManager sharedManager] updateDocumentsInFolderWithName:self.lastFolderName withAttributes:responseDict];

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdatingDocumentsFailed:
            {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsIn400Range:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    // And recursively call the update to force a renewal of the access token
                    [self updateDocumentsInFolderWithName:self.lastFolderName folderUri:self.lastFolderUri withSuccess:^{
                        if (self.lastSuccessBlock) {
                            self.lastSuccessBlock();
                        }
                    } failure:^(NSError *error) {
                        if (self.lastFailureBlock) {
                            self.lastFailureBlock(self.lastError);
                        }
                    }];
                } else if (![self requestWasCancelledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

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
                if ([self responseCodeIsIn400Range:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [[SHCOAuthManager sharedManager] removeAccessToken];

                    // And recursively call the download to force a renewal of the access token
                    [self downloadAttachment:self.lastAttachment withProgress:self.lastProgress success:^{
                        if (self.lastSuccessBlock) {
                            self.lastSuccessBlock();
                        }
                    } failure:^(NSError *error) {
                        if (self.lastFailureBlock) {
                            self.lastFailureBlock(self.lastError);
                        }
                    }];
                } else if (![self requestWasCancelledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateValidatingAccessToken:
            case SHCAPIManagerStateUpdatingRootResource:
            case SHCAPIManagerStateUpdatingDocuments:
            case SHCAPIManagerStateDownloadingAttachment:
            case SHCAPIManagerStateIdle:
            default:
                break;
        }
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
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingRootResource
{
    [self cancelRequestsWithPath:__ROOT_RESOURCE_URI__];
}

- (void)updateDocumentsInFolderWithName:(NSString *)folderName folderUri:(NSString *)folderUri withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    [self validateTokensWithSuccess:^{
        self.state = SHCAPIManagerStateUpdatingDocuments;

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
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingDocuments
{
    [self cancelRequestsWithPath:self.lastFolderUri];
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
            if (error) {
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

- (void)cancelDownloadingAttachments
{
    for (NSURLSessionDownloadTask *downloadTask in self.sessionManager.downloadTasks) {
        [downloadTask cancel];
    }
}

- (BOOL)responseCodeIsIn400Range:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if ([HTTPResponse statusCode] >= 400 && ([HTTPResponse statusCode] < 500)) {
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
        DDLogError(@"[Error] %@ %@ (%ld): %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, error);
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
        DDLogInfo(@"%u requests cancelled", counter);
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
