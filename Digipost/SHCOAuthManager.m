//
//  SHCOAuthManager.m
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>
#import "SHCOAuthManager.h"
#import "NSString+RandomNumber.h"
#import "LUKeychainAccess.h"
#import "UIAlertView+Blocks.h"
#import "SHCLoginViewController.h"

// Custom NSError code enum
typedef NS_ENUM(NSUInteger, SHCOAuthErrorCode) {
    SHCOAuthErrorCodeMissingAccessTokenResponse = 1,
};

// Digipost OAuth2 API consts
NSString *const kOAuth2ClientID = @"client_id";
NSString *const kOAuth2RedirectURI = @"redirect_uri";
NSString *const kOAuth2ResponseType = @"response_type";
NSString *const kOAuth2State = @"state";
NSString *const kOAuth2Code = @"code";
NSString *const kOAuth2GrantType = @"grant_type";
NSString *const kOAuth2Nonce = @"nonce";
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
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                                   sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:__OAUTH_CLIENT_ID__ password:__OAUTH_SECRET__];

        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
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
                                 kOAuth2RedirectURI: __OAUTH_REDIRECT_URI__};

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
                                 kOAuth2RedirectURI: __OAUTH_REDIRECT_URI__};

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
                          // Check to see if the request failed because the refresh token was denied
                          NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)task.response;
                          if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                              if ([HTTPResponse statusCode] >= 400 && ([HTTPResponse statusCode] < 500)) {

                                  [self removeAllTokens];

                                  // The refresh token was rejected, most likely because the user invalidated
                                  // the session in the www.digipost.no web settings interface.
                                  [UIAlertView showWithTitle:NSLocalizedString(@"GENERIC_REFRESH_TOKEN_INVALID_TITLE", @"Refresh token invalid title")
                                                     message:NSLocalizedString(@"GENERIC_REFRESH_TOKEN_INVALID_MESSAGE", @"Refresh token invalid message")
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@[NSLocalizedString(@"GENERIC_OK_BUTTON_TITLE", @"OK")]
                                                    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kPopToLoginViewControllerNotificationName object:nil];
                                                    }];
                                  return;
                              }
                          }

                          if (failure) {
                              failure(error);
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
}

@end
