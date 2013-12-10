//
//  SHCOAuthViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCOAuthViewController.h"
#import "UIWebView+OAuth2.h"
#import "NSString+RandomNumber.h"
#import "NSURLRequest+QueryParameters.h"

@interface SHCOAuthViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *stateParameter;

@end

@implementation SHCOAuthViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.stateParameter = [NSString randomNumberString];

    // TODO: change to something more flexible
    [self.webView authenticateWithClientID:@"bc070447ff37466cbe93ec52c94a9239"
                               redirectURI:@"http://localhost:7890"
                              responseType:@"code"
                                     state:@"12345"];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // When localhost is trying to load, it means the app is trying to log in with OAuth2
    if ([request.URL.host isEqualToString:@"localhost"]) {

        NSDictionary *parameters = [request queryParameters];

        if (parameters[kOAuth2State]) {
            NSString *state = parameters[kOAuth2State];

            NSString *currentState = [self.stateParameter copy];

            // Reset the state parameter, as we're done checking its value for now
            self.stateParameter = nil;

            if (![state isEqualToString:self.stateParameter]) {
                // TODO: log error and resend request
            }

        } else {
            NSAssert(NO, @"No state parameter sent, this should not happen");
        }

        [self webViewRequestOauthToken:dictionary];
        return NO;
    }
}

@end
