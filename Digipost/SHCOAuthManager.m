// 
// Copyright (C) Posten Norge AS
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <AFNetworking/AFHTTPSessionManager.h>
#import "SHCOAuthManager.h"
#import "NSString+RandomNumber.h"
#import "LUKeychainAccess.h"
#import "SHCAPIManager.h"
#import "SHCFileManager.h"
#import "oauth.h"

// Digipost OAuth2 API consts
NSString *const kOAuth2ClientID = @"client_id";
NSString *const kOAuth2RedirectURI = @"redirect_uri";
NSString *const kOAuth2ResponseType = @"response_type";
NSString *const kOAuth2State = @"state";
NSString *const kOAuth2Code = @"code";
NSString *const kOAuth2GrantType = @"grant_type";
NSString *const kOAuth2AccessToken = @"access_token";
NSString *const kOAuth2RefreshToken = @"refresh_token";

// Internal Keychain key consts
NSString *const kKeychainAccessRefreshTokenKey = @"refresh_token";

// Custom NSError consts
NSString *const kOAuth2ErrorDomain = @"OAuth2ErrorDomain";

@interface SHCOAuthManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation SHCOAuthManager

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:__SERVER_URI__];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;

        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                                   sessionConfiguration:configuration];

        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:OAUTH_CLIENT_ID password:OAUTH_SECRET];

        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];

#if (__ACCEPT_SELF_SIGNED_CERTIFICATES__)

        _sessionManager.securityPolicy.allowInvalidCertificates = YES;

#endif
    }

    return self;
}

#pragma mark - Properties

- (NSString *)refreshToken
{
    NSString *refreshToken = [[LUKeychainAccess standardKeychainAccess] stringForKey:kKeychainAccessRefreshTokenKey];

    return refreshToken;
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    [[LUKeychainAccess standardKeychainAccess] setString:refreshToken forKey:kKeychainAccessRefreshTokenKey];
}

#pragma mark - Public methods

+ (instancetype)sharedManager
{
    static SHCOAuthManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SHCOAuthManager alloc] init];
    });

    return sharedInstance;
}

- (void)authenticateWithCode:(NSString *)code success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    // First, remove any previous access and refresh tokens
    _accessToken = nil;
    self.refreshToken = nil;

    NSDictionary *parameters = @{kOAuth2GrantType: kOAuth2Code,
                                 kOAuth2Code: code,
                                 kOAuth2RedirectURI: OAUTH_REDIRECT_URI};

    [self.sessionManager POST:__ACCESS_TOKEN_URI__
                   parameters:parameters
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          NSDictionary *responseDict = (NSDictionary *)responseObject;
                          if ([responseDict isKindOfClass:[NSDictionary class]]) {

                              NSString *refreshToken = responseDict[kOAuth2RefreshToken];
                              if ([refreshToken isKindOfClass:[NSString class]]) {
                                  self.refreshToken = refreshToken;
                              }

                              NSString *accessToken = responseDict[kOAuth2AccessToken];
                              if ([accessToken isKindOfClass:[NSString class]]) {
                                  _accessToken = accessToken;

                                  // We only call the success block if the access token is set.
                                  // The refresh token is not strictly neccesary at this point.
                                  if (success) {
                                      success();
                                      return;
                                  }
                              }
                          }

                          if (failure) {
                              NSError *error = [NSError errorWithDomain:kOAuth2ErrorDomain
                                                                   code:SHCOAuthErrorCodeMissingAccessTokenResponse
                                                               userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"OAUTH_MANAGER_MISSING_ACCESS_TOKEN_RESPONSE", @"Missing access token response")}];
                              failure(error);
                          }

                      } failure:^(NSURLSessionDataTask *task, NSError *error) {
                          if (failure) {
                              failure(error);
                          }
                      }];
}

- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    // First, remove previous access token
    _accessToken = nil;

    NSDictionary *parameters = @{kOAuth2GrantType: kOAuth2RefreshToken,
                                 kOAuth2RefreshToken: refreshToken,
                                 kOAuth2RedirectURI: OAUTH_REDIRECT_URI};

    [self.sessionManager POST:__ACCESS_TOKEN_URI__
                   parameters:parameters
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          NSDictionary *responseDict = (NSDictionary *)responseObject;
                          if ([responseDict isKindOfClass:[NSDictionary class]]) {

                              NSString *accessToken = responseDict[kOAuth2AccessToken];
                              if ([accessToken isKindOfClass:[NSString class]]) {
                                  _accessToken = accessToken;

                                  DDLogInfo(@"Access token updated");

                                  if (success) {
                                      success();
                                      return;
                                  }
                              }
                          }

                          if (failure) {
                              NSError *error = [NSError errorWithDomain:kOAuth2ErrorDomain
                                                                   code:SHCOAuthErrorCodeMissingAccessTokenResponse
                                                               userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"OAUTH_MANAGER_MISSING_ACCESS_TOKEN_RESPONSE", @"Missing access token response")}];
                              failure(error);
                          }

                      } failure:^(NSURLSessionDataTask *task, NSError *error) {

                          if (failure) {
                              // Check to see if the request failed because the refresh token was denied

                              if ([[SHCAPIManager sharedManager] responseCodeForOAuthIsUnauthorized:task.response]) {
                                  NSError *customError = [NSError errorWithDomain:kOAuth2ErrorDomain
                                                                             code:SHCOAuthErrorCodeInvalidRefreshTokenResponse
                                                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"GENERIC_REFRESH_TOKEN_INVALID_MESSAGE", @"Refresh token invalid message")}];
                                  failure(customError);
                              } else {
                                  failure(error);
                              }
                          }
                      }];
}

- (void)removeAccessToken
{
    _accessToken = nil;

    DDLogInfo(@"Access token removed");
}

- (void)removeAllTokens
{
    _accessToken = nil;
    self.refreshToken = nil;

    DDLogInfo(@"All tokens removed");
    NSString *refreshToken = [[LUKeychainAccess standardKeychainAccess] stringForKey:kKeychainAccessRefreshTokenKey];
    NSAssert(refreshToken == nil, @"refresh token not nil!");
    refreshToken = nil;
    [[SHCFileManager sharedFileManager] removeAllFiles];
}

@end
