//
//  SHCBaseEncryptedModel.m
//  Digipost
//
//  Created by Eivind Bohler on 20.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCBaseEncryptedModel.h"
#import "SHCFileManager.h"
#import "SHCModelManager.h"
#import "SHCBaseEncryptedModel.h"
#import "NSString+SHA1String.h"

@implementation SHCBaseEncryptedModel

@dynamic uri;
@dynamic fileType;

- (NSString *)encryptedFilePath
{
    NSString *fileName = [[self.uri SHA1String] stringByAppendingString:[NSString stringWithFormat:@".%@", self.fileType]];

    if (!fileName) {
        return nil;
    }

    NSString *filePath = [[[SHCFileManager sharedFileManager] encryptedFilesFolderPath] stringByAppendingPathComponent:fileName];

    return filePath;
}

- (NSString *)decryptedFilePath
{
    NSString *fileName = [[self.uri SHA1String] stringByAppendingString:[NSString stringWithFormat:@".%@", self.fileType]];

    if (!fileName) {
        return nil;
    }

    NSString *filePath = [[[SHCFileManager sharedFileManager] decryptedFilesFolderPath] stringByAppendingPathComponent:fileName];

    return filePath;
}

@end
