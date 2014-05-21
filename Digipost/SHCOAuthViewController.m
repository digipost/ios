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

#import <UIAlertView+Blocks.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import "SHCOAuthViewController.h"
#import "NSString+RandomNumber.h"
#import "NSURLRequest+QueryParameters.h"
#import "SHCOAuthManager.h"
#import "NSError+ExtraInfo.h"
#import "oauth.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPresentOAuthModallyIdentifier = @"PresentOAuthModally";

// Google Analytics screen name
NSString *const kOAuthViewControllerScreenName = @"OAuth";

@interface SHCOAuthViewController () <UIWebViewDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *stateParameter;

#if (__ACCEPT_SELF_SIGNED_CERTIFICATES__)
@property (assign, nonatomic, getter=isAuthenticated) BOOL authenticated;
@property (strong, nonatomic) NSURLRequest *failedURLRequest;
#endif

@end

@implementation SHCOAuthViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.screenName = kOAuthViewControllerScreenName;

    self.navigationItem.title = NSLocalizedString(@"OAUTH_VIEW_CONTROLLER_NAVIGATION_ITEM_TITLE", @"Sign In");

    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel");
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0
                                                                                                                            alpha:0.8] }
                                                             forState:UIControlStateNormal];
    }

    [self presentAuthenticationWebView];

    [self.webView setKeyboardDisplayRequiresUserAction:NO];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // When localhost is trying to load, it means the app is trying to log in with OAuth2
    if ([request.URL.host isEqualToString:@"localhost"]) {

        NSDictionary *parameters = [request queryParameters];

        if (parameters[kOAuth2State]) {
            NSString *state = parameters[kOAuth2State];

            // Copy and reset the state parameter, as we're done checking its value for now
            NSString *currentState = [self.stateParameter copy];
            self.stateParameter = nil;

            if (![state isEqualToString:currentState]) {

                [self presentAuthenticationWebView];
                return NO;
            }

        } else {
            NSAssert(NO, @"No state parameter sent, this should not happen");
        }

        if (parameters[kOAuth2Code]) {
            [[SHCOAuthManager sharedManager] authenticateWithCode:parameters[kOAuth2Code]
                success:^{

                // The OAuth manager has successfully authenticated with code - which means we've
                // got an access code and a refresh code, and can dismiss this view controller
                // and let the login view controller take over and push the folders view controller.
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([self.delegate respondsToSelector:@selector(OAuthViewControllerDidAuthenticate:)]) {
                        [self.delegate OAuthViewControllerDidAuthenticate:self];
                    }
                }];
                }
                failure:^(NSError *error) {
                [UIAlertView showWithTitle:error.errorTitle
                                   message:[error localizedDescription]
                         cancelButtonTitle:nil
                         otherButtonTitles:@[error.okButtonTitle]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      [self presentAuthenticationWebView];
                                  }];
                }];
        } else {
            NSAssert(NO, @"No code parameter sent, this should not happen");
        }

        return NO;
    }

#if (__ACCEPT_SELF_SIGNED_CERTIFICATES__)

    if (!self.isAuthenticated) {
        self.failedURLRequest = request;
        __unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                               delegate:self];
    }

    return self.isAuthenticated;

#endif

    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIAlertView showWithTitle:error.errorTitle
                       message:[error localizedDescription]
             cancelButtonTitle:nil
             otherButtonTitles:@[ error.okButtonTitle ]
                      tapBlock:error.tapBlock];
}

#if (__ACCEPT_SELF_SIGNED_CERTIFICATES__)

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {

        NSURL *baseURL = [NSURL URLWithString:__SERVER_URI__];
        if ([challenge.protectionSpace.host isEqualToString:baseURL.host]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
                 forAuthenticationChallenge:challenge];
        } else {
            DDLogError(@"Not trusting connection to host %@", challenge.protectionSpace.host);
        }
    }

    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.authenticated = YES;

    [connection cancel];

    [self.webView loadRequest:self.failedURLRequest];
}

#endif

#pragma mark - Private methods

- (void)presentAuthenticationWebView
{
    self.stateParameter = [NSString randomNumberString];

    NSDictionary *parameters = @{kOAuth2ClientID : OAUTH_CLIENT_ID,
                                 kOAuth2RedirectURI : OAUTH_REDIRECT_URI,
                                 kOAuth2ResponseType : kOAuth2Code,
                                 kOAuth2State : self.stateParameter};

    [self authenticateWithParameters:parameters];
}

- (void)authenticateWithParameters:(NSDictionary *)parameters
{
    NSString *URLString = [__SERVER_URI__ stringByAppendingPathComponent:__AUTHENTICATION_URI__];

    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                          URLString:URLString
                                                                         parameters:parameters];
    [self.webView loadRequest:request];
}

@end
