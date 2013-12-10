//
//  SHCOAuthManager.h
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kOAuth2ClientID;
extern NSString *const kOAuth2RedirectURI;
extern NSString *const kOAuth2ResponseType;
extern NSString *const kOAuth2State;
extern NSString *const kOAuth2Code;

@interface SHCOAuthManager : NSObject

+ (instancetype)sharedManager;

- (void)authenticateWithCode:(NSString *)code success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
