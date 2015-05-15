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

#import <UIAlertView_Blocks/UIAlertView+Blocks.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import "SHCOAuthViewController.h"
#import "NSString+RandomNumber.h"
#import "NSURLRequest+QueryParameters.h"
#import "POSOAuthManager.h"
#import "NSError+ExtraInfo.h"
#import "GAIDictionaryBuilder.h"
#import "oauth.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPresentOAuthModallyIdentifier = @"PresentOAuthModally";

// Google Analytics screen name
NSString *const kOAuthViewControllerScreenName = @"OAuth";

NSString *const kGoogleAnalyticsErrorEventCategory = @"Error";
NSString *const kGoogleAnalyticsErrorEventAction = @"OAuth";

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

    [self.navigationController setNavigationBarHidden:NO animated:NO];

    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;

    if (self.scope == kOauth2ScopeFull) {
        if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
            self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel");
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0
                                                                                                                                alpha:0.8] }
                                                                 forState:UIControlStateNormal];
        }
    } else {
        [self setupUIForIncreasedAuthenticationLevelVC];
    }

    [self presentAuthenticationWebView];

    [self.webView setKeyboardDisplayRequiresUserAction:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setupUIForIncreasedAuthenticationLevelVC
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel") style:UIBarButtonItemStyleDone target:self action:@selector(didTapCloseBarButtonItem:)];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0
                                                                                                                        alpha:0.8] }

                                                         forState:UIControlStateNormal];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    // Trap requests to the URL used when OAuth authentication dialog finishes
    if ([request.URL.absoluteString hasPrefix:OAUTH_REDIRECT_URI]) {
        NSDictionary *parameters = [request queryParameters];

        if (parameters[kOAuth2State]) {
            NSString *state = parameters[kOAuth2State];

            // Copy and reset the state parameter, as we're done checking its value for now
            NSString *currentState = [self.stateParameter copy];
            self.stateParameter = nil;

            if ([state isEqualToString:currentState] == NO) {
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGoogleAnalyticsErrorEventCategory action:kGoogleAnalyticsErrorEventAction label:@"State parameter differ from stored value" value:nil] build]];
                [self informUserThatOauthFailedThenDismissViewController];
                return NO;
            }
        } else {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGoogleAnalyticsErrorEventCategory action:kGoogleAnalyticsErrorEventAction label:@"Missing state parameter" value:nil] build]];
            [self informUserThatOauthFailedThenDismissViewController];
            return NO;
        }

        if (parameters[kOAuth2Code]) {
            [[POSOAuthManager sharedManager] authenticateWithCode:parameters[kOAuth2Code]
                scope:self.scope
                success:^{

                  // The OAuth manager has successfully authenticated with code - which means we've
                  // got an access code and a refresh code, and can dismiss this view controller
                  // and let the login view controller take over and push the folders view controller.
                  [self dismissViewControllerAnimated:YES
                                           completion:^{
                                             if ([self.delegate respondsToSelector:@selector(OAuthViewControllerDidAuthenticate:scope:)]) {
                                                 [self.delegate OAuthViewControllerDidAuthenticate:self scope:self.scope];
                                             }
                                           }];
                }
                failure:^(NSError *error) {
                  [UIAlertView showWithTitle:error.errorTitle
                                     message:[error localizedDescription]
                           cancelButtonTitle:nil
                           otherButtonTitles:@[ error.okButtonTitle ]
                                    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      [self presentAuthenticationWebView];
                                    }];
                }];
        } else {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGoogleAnalyticsErrorEventCategory action:kGoogleAnalyticsErrorEventAction label:@"Missing code parameter" value:nil] build]];
            [self informUserThatOauthFailedThenDismissViewController];
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

- (void)informUserThatOauthFailedThenDismissViewController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Oauth login error title", @"title for informing user that something critical is wrong") message:NSLocalizedString(@"Oauth login error message", @"message for informing user that Oauth state is wrong") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Oauth login error button title", @"Lets user tap it to dismiss alert")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                        [self dismissViewControllerAnimated:YES completion:nil];
                                                      }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // the -999 code is a code that happens every time oauth is done
    if (error.code != -999) {
        [UIAlertView showWithTitle:error.errorTitle
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[ error.okButtonTitle ]
                          tapBlock:error.tapBlock];
    }
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
            //   DDLogError(@"Not trusting connection to host %@", challenge.protectionSpace.host);
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

- (void)didTapCloseBarButtonItem:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{

                             }];
}

- (void)presentAuthenticationWebView
{
    NSAssert(self.scope != nil, @"must set scope before asking for authentication");
    self.stateParameter = [NSString randomNumberString];

    NSDictionary *parameters = @{kOAuth2ClientID : OAUTH_CLIENT_ID,
                                 kOAuth2RedirectURI : OAUTH_REDIRECT_URI,
                                 kOAuth2ResponseType : kOAuth2Code,
                                 kOAuth2State : self.stateParameter,
                                 kOAuth2Scope : [self parameterForOauth2Scope:self.scope]};

    [self authenticateWithParameters:parameters];
}

- (NSString *)parameterForOauth2Scope:(NSString *)scope
{
    if ([scope isEqualToString:kOauth2ScopeFull]) {
        return @"FULL";
    } else if ([scope isEqualToString:kOauth2ScopeFullHighAuth]) {
        return @"FULL_HIGHAUTH";
    } else if ([scope isEqualToString:kOauth2ScopeFull_Idporten3]) {
        return @"FULL_IDPORTEN3";
    } else if ([scope isEqualToString:kOauth2ScopeFull_Idporten4]) {
        return @"FULL_IDPORTEN4";
    }
    return nil;
}

- (void)authenticateWithParameters:(NSDictionary *)parameters
{
    NSString *URLString = [__SERVER_URI__ stringByAppendingPathComponent:__AUTHENTICATION_URI__];
    NSError *error;
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:parameters error:&error];
    [self.webView loadRequest:request];
}

@end
