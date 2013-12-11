//
//  SHCNetworkClient.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCNetworkClient.h"

@implementation SHCNetworkClient

#pragma mark - Public methods

+ (instancetype)sharedClient
{
    static SHCNetworkClient *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SHCNetworkClient alloc] init];
    });

    return sharedInstance;
}

@end
