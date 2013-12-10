//
//  UIWebView+OAuth2.h
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (OAuth2)

- (void)authenticateWithParameters:(NSDictionary *)parameters;

@end
