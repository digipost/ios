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
    SHCAPIManagerStateUpdatingDocumentsFailed
};

static void *kSHCAPIManagerStateContext = &kSHCAPIManagerStateContext;
static void *kSHCAPIManagerRequestWasSuspended = &kSHCAPIManagerRequestWasSuspended;

@interface SHCAPIManager ()

@property (assign, nonatomic) SHCAPIManagerState state;
@property (copy, nonatomic) void(^lastSuccessBlock)(void);
@property (copy, nonatomic) void(^lastFailureBlock)(NSError *);
@property (strong, nonatomic) NSURLSessionDataTask *lastSessionDataTask;
@property (strong, nonatomic) id lastResponseObject;
@property (copy, nonatomic) NSString *lastFolderName;
@property (strong, nonatomic) NSError *lastError;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

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
                if ([self responseCodeIsIn400Range:self.lastSessionDataTask.response]) {

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
                } else {
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
                break;
            }
            case SHCAPIManagerStateValidatingAccessToken:
            case SHCAPIManagerStateUpdatingRootResource:
            case SHCAPIManagerStateUpdatingDocuments:
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
                             self.lastSessionDataTask = task;
                             self.lastResponseObject = responseObject;
                             self.state = SHCAPIManagerStateUpdatingRootResourceFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastSessionDataTask = task;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingRootResourceFailed;
                        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateDocumentsInFolderWithName:(NSString *)folderName folderUri:(NSString *)folderUri withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    [self validateTokensWithSuccess:^{
        self.state = SHCAPIManagerStateUpdatingDocuments;

        [self.sessionManager GET:folderUri
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastSessionDataTask = task;
                             self.lastResponseObject = responseObject;
                             self.lastFolderName = folderName;
                             self.state = SHCAPIManagerStateUpdatingDocumentsFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastSessionDataTask = task;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingDocumentsFailed;
                         }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
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

- (BOOL)responseCodeIsIn400Range:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)self.lastSessionDataTask.response;
    if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if ([HTTPResponse statusCode] >= 400 && ([HTTPResponse statusCode] < 500)) {
            return YES;
        }
    }

    return NO;
}

- (void)cleanup
{
    self.lastSuccessBlock = nil;
    self.lastFailureBlock = nil;
    self.lastSessionDataTask = nil;
    self.lastResponseObject = nil;
    self.lastFolderName = nil;
    self.lastError = nil;

    self.state = SHCAPIManagerStateIdle;
}

@end
