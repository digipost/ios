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

// Digipost OAuth2 API consts
extern NSString *const kOAuth2ClientID;
extern NSString *const kOAuth2RedirectURI;
extern NSString *const kOAuth2ResponseType;
extern NSString *const kOAuth2State;
extern NSString *const kOAuth2Code;

// Custom NSError consts
extern NSString *const kOAuth2ErrorDomain;

@interface SHCOAuthManager : NSObject

@property (copy, nonatomic, readonly) NSString *accessToken;
@property (copy, nonatomic, readonly) NSString *refreshToken;

+ (instancetype)sharedManager;

- (void)authenticateWithCode:(NSString *)code success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)removeAccessToken;
- (void)removeAllTokens;

@end
