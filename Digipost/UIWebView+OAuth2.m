//
//  UIWebView+OAuth2.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "UIWebView+OAuth2.h"
#import <AFNetworking/AFNetworking.h>

@implementation UIWebView (OAuth2)

- (void)authenticateWithParameters:(NSDictionary *)parameters
{
    NSString *URLString = [__SERVER_URI__ stringByAppendingPathComponent:__AUTHENTICATION_URI__];

    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                          URLString:URLString
                                                                         parameters:parameters];
    [self loadRequest:request];
}

@end
