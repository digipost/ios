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

NSString *const kOAuth2ClientID = @"client_id";
NSString *const kOAuth2RedirectURI = @"redirect_uri";
NSString *const kOAuth2ResponseType = @"response_type";
NSString *const kOAuth2State = @"state";
NSString *const kOAuth2Code = @"code";
NSString *const kOAuth2GrantType = @"grant_type";
NSString *const kOAuth2Nonce = @"nonce";

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
    NSString *nonce = [NSString randomNumberString];

    NSDictionary *parameters = @{kOAuth2GrantType: kOAuth2Code,
                                 kOAuth2Code: code,
                                 kOAuth2RedirectURI: __OAUTH_REDIRECT_URI__,
                                 kOAuth2Nonce: nonce};

    NSURLSessionDataTask *task = [self.sessionManager POST:__ACCESS_TOKEN_URI__
                                                parameters:parameters
                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                                       if (success) {
                                                           success();
                                                       }
                                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {

                                                   }];
    [task resume];
}

@end
