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
#import "1PasswordExtension/OnePasswordExtension.h"
#import "SHCOAuthViewController.h"
#import "NSString+RandomNumber.h"
#import "NSURLRequest+QueryParameters.h"
#import "POSOAuthManager.h"
#import "NSError+ExtraInfo.h"
#import "GAIDictionaryBuilder.h"
#import "oauth.h"
#import "Digipost-Swift.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPresentOAuthModallyIdentifier = @"PresentOAuthModally";

// Google Analytics screen name
NSString *const kOAuthViewControllerScreenName = @"OAuth";

NSString *const kGoogleAnalyticsErrorEventCategory = @"Error";
NSString *const kGoogleAnalyticsErrorEventAction = @"OAuth";
Boolean tryToFillUsing1Password = false;

@interface SHCOAuthViewController () <UIWebViewDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *stateParameter;

#if (ACCEPT_SELF_SIGNED_CERTIFICATES)
@property (assign, nonatomic, getter=isAuthenticated) BOOL authenticated;
@property (strong, nonatomic) NSURLRequest *failedURLRequest;
#endif

@end

@implementation SHCOAuthViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self clearCacheAndCookies];
    self.screenName = kOAuthViewControllerScreenName;

    self.navigationItem.title = NSLocalizedString(@"OAUTH_VIEW_CONTROLLER_NAVIGATION_ITEM_TITLE", @"Sign In");

    [self.navigationController setNavigationBarHidden:NO animated:NO];

    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;

    [self remove1PasswordButtonIfNotNormalLoginScope];
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

    // The existing OAuth implementation will normally nil the oauth-state variabel when this view is not longer visible (normally because a successfull login). But because this method will also be invoked when the app tries to open 1Password, we need to _not_ nil the the state when returning from 1Password. tryToFillUsing1Password is set to true in the fillUsing1Password-method.
    if (tryToFillUsing1Password) {
        tryToFillUsing1Password = false;
    }else{
        self.stateParameter = nil;
    }
}

- (void)setupUIForIncreasedAuthenticationLevelVC
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel") style:UIBarButtonItemStyleDone target:self action:@selector(didTapCloseBarButtonItem:)];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0
                                                                                                                        alpha:0.8] }

                                                         forState:UIControlStateNormal];
}

-(void)clearCacheAndCookies{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // Trap requests to the URL used when OAuth authentication dialog finishes
    if ([request.URL.absoluteString hasPrefix:OAUTH_REDIRECT_URI]) {
        NSDictionary *parameters = [request queryParameters];

        if (parameters[kOAuth2State]) {
            NSString *state = parameters[kOAuth2State];
            // Copy and reset the state parameter, as we're done checking its value for now
            NSString *currentState = [self.stateParameter copy];
            self.stateParameter = nil;
            if ([state isEqualToString:currentState] == NO) {
               // [Logger dpostLogError:@"State parameter returned from server differed from what client sent" location:@"Showing OAuth login screen" UI:@"User will get an error and be asked to try logging in again" cause:@"Server is broken or possible man in the middle attack"];
                [self informUserThatOauthFailedThenDismissViewController];
                return NO;
            }
        } else {
            // [Logger dpostLogError:@"Could not find OAuth state-paramter in json sent from server" location:@"Shows a modal login view" UI:@"User will get an error message and asked to try logging in again" cause:@"Server has issues or something hijacked the web traffic from app"];
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
            // [Logger dpostLogError:@"Could not find OAuth code-paramter in json sent from server" location:@"Shows a modal login view" UI:@"User will get an error message and asked to try logging in again" cause:@"Server has issues or something hijacked the web traffic from app"];
            [self informUserThatOauthFailedThenDismissViewController];
        }

        return NO;
    }

#if (ACCEPT_SELF_SIGNED_CERTIFICATES)

    if (!self.isAuthenticated) {
        self.failedURLRequest = request;
        __unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                               delegate:self];
    }

    return self.isAuthenticated;

#endif

    return YES;
}

- (void) remove1PasswordButtonIfNotNormalLoginScope {
    if (self.scope != kOauth2ScopeFull) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (IBAction)fillUsing1Password:(id)sender {
    tryToFillUsing1Password = true;
    [[OnePasswordExtension sharedExtension] fillItemIntoWebView:self.webView forViewController:self sender:sender showOnlyLogins:YES completion:^(BOOL success, NSError *error) {
        if (!success && error.code != 0) {
            NSLog(@"Failed to fill into webview: <%@>", error);
        }
    }];
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

#if (ACCEPT_SELF_SIGNED_CERTIFICATES)

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
    self.stateParameter = [NSString secureRandomString];

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
