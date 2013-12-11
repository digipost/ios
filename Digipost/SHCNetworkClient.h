//
//  SHCNetworkClient.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHCNetworkClient : NSObject

+ (instancetype)sharedClient;

- (void)updateRootResourceWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
