//
//  SHCFileManager.m
//  Digipost
//
//  Created by Eivind Bohler on 02.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCFileManager.h"

@implementation SHCFileManager

#pragma mark - Public methods

+ (instancetype)sharedFileManager
{
    static SHCFileManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SHCFileManager alloc] init];
    });

    return sharedInstance;
}

- (NSData *)fileDataForUri:(NSString *)uri
{
    NSData *fileData = nil;

    // TODO: generate a filename based on the uri,
    //       load this file if it exists,
    //       decrypt its content and return the data.

    return fileData;
}

- (void)setFileData:(NSData *)fileData forUri:(NSString *)uri
{
    // TODO: Encrypt the data,
    //       generate a filename based on the uri and save.
}

@end
