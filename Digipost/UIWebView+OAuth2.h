//
//  UIWebView+OAuth2.h
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kOAuth2State;

@interface UIWebView (OAuth2)

- (void)authenticateWithClientID:(NSString *)clientID
                     redirectURI:(NSString *)redirectURI
                    responseType:(NSString *)responseType
                           state:(NSString *)state;

@end
