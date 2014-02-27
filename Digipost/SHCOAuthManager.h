//
//  SHCOAuthManager.h
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
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
