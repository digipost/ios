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
#import "SHCOAuthManager.h"
#import "UIAlertView+Blocks.h"

NSString *const kPresentOAuthModallyIdentifier = @"PresentOAuthModally";

NSString *const kOAuth2ClientID = @"client_id";
NSString *const kOAuth2RedirectURI = @"redirect_uri";
NSString *const kOAuth2ResponseType = @"response_type";
NSString *const kOAuth2State = @"state";
NSString *const kOAuth2Code = @"code";

@interface SHCOAuthViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *stateParameter;

@end

@implementation SHCOAuthViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self presentAuthenticationWebView];
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
            [[SHCOAuthManager sharedManager] authenticateWithCode:parameters[kOAuth2Code] success:^{

                // The OAuth manager has successfully authenticated with code - which means we've
                // got an access code and a refresh code, and can dismiss this view controller
                // and let the login view controller take over and push the folders view controller.
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([self.delegate respondsToSelector:@selector(OAuthViewControllerDidAuthenticate:)]) {
                        [self.delegate OAuthViewControllerDidAuthenticate:self];
                    }
                }];

            } failure:^(NSError *error) {
                [UIAlertView showWithTitle:NSLocalizedString(@"OAUTH_VIEW_CONTROLLER_AUTHENTICATE_WITH_CODE_ERROR_TITLE", @"Error")
                                   message:[error localizedDescription]
                         cancelButtonTitle:nil
                         otherButtonTitles:@[NSLocalizedString(@"OAUTH_VIEW_CONTROLLER_AUTHENTICATE_WITH_CODE_OK_BUTTON_TITLE", @"OK")]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      [self presentAuthenticationWebView];
                                  }];

            }];
        } else {
            NSAssert(NO, @"No code parameter sent, this should not happen");
        }

        return NO;
    }

    return YES;
}

#pragma mark - Private methods

- (void)presentAuthenticationWebView
{
    self.stateParameter = [NSString randomNumberString];

    NSDictionary *parameters = @{kOAuth2ClientID: __OAUTH_CLIENT_ID__,
                                 kOAuth2RedirectURI: __OAUTH_REDIRECT_URI__,
                                 kOAuth2ResponseType: kOAuth2Code,
                                 kOAuth2State: self.stateParameter};

    [self.webView authenticateWithParameters:parameters];
}

@end
