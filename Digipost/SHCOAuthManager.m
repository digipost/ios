//
//  SHCOAuthManager.m
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCOAuthManager.h"

@implementation SHCOAuthManager

#pragma mark - Public methods

+ (instancetype)sharedManager
{
    static SHCOAuthManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SHCOAuthManager alloc] init];
    });

    return sharedInstance;
}

- (void)authenticateWithCode:(NSString *)code success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    if (success) {
        success();
    }
}

@end
