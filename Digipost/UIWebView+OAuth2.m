//
//  UIWebView+OAuth2.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "UIWebView+OAuth2.h"
#import <AFNetworking/AFNetworking.h>

NSString *const kOAuth2ClientID = @"client_id";
NSString *const kOAuth2RedirectURI = @"redirect_uri";
NSString *const kOAuth2ResponseType = @"response_type";
NSString *const kOAuth2State = @"state";

@implementation UIWebView (OAuth2)

- (void)authenticateWithClientID:(NSString *)clientID
                     redirectURI:(NSString *)redirectURI
                    responseType:(NSString *)responseType
                           state:(NSString *)state

{
    NSDictionary *parameters = @{kOAuth2ClientID: clientID,
                                 kOAuth2RedirectURI: redirectURI,
                                 kOAuth2ResponseType: responseType,
                                 kOAuth2State: state};

    NSString *URLString = [__SERVER_URL__ stringByAppendingPathComponent:__AUTHENTICATION_URL__];

    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                          URLString:URLString
                                                                         parameters:parameters];
    [self loadRequest:request];
}

@end
