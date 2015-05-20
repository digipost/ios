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

#import <Foundation/Foundation.h>

// Custom NSError code enum
typedef NS_ENUM(NSUInteger, SHCOAuthErrorCode) {
    SHCOAuthErrorCodeMissingAccessTokenResponse = 1,
    SHCOAuthErrorCodeInvalidRefreshTokenResponse
};

// Custom NSError consts
extern NSString *const kAPIManagerErrorDomain;

// Notification names
extern NSString *const kAPIManagerUploadProgressStartedNotificationName;
extern NSString *const kAPIManagerUploadProgressChangedNotificationName;
extern NSString *const kAPIManagerUploadProgressFinishedNotificationName;


// Digipost OAuth2 API consts
extern NSString *const kOAuth2ClientID;
extern NSString *const kOAuth2RedirectURI;
extern NSString *const kOAuth2ResponseType;
extern NSString *const kOAuth2State;
extern NSString *const kOAuth2Code;
extern NSString *const kOAuth2Scope;
extern NSString *const kOauth2ScopeFull;
extern NSString *const kOauth2ScopeFullHighAuth;
extern NSString *const kOauth2ScopeFull_Idporten3;
extern NSString *const kOauth2ScopeFull_Idporten4;
extern NSString *const kKeychainAccessRefreshTokenKey;
extern NSString *const kOAuth2IDToken;

extern NSString *const kOAuth2AccessToken;
extern NSString *const kOAuth2RefreshToken;
extern NSString *const kOAuth2TokensKey;

// Custom NSError consts
extern NSString *const kOAuth2ErrorDomain;

@interface POSOAuthManager : NSObject

+ (instancetype)sharedManager;

- (void)authenticateWithCode:(NSString *)code scope:(NSString *)scope nonce:(NSString *)nonce success:(void (^)(void))success failure:(void (^)(NSError *))failure;
- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken scope:(NSString *)scope success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
