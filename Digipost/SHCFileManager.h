//
//  SHCFileManager.h
//  Digipost
//
//  Created by Eivind Bohler on 02.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHCAttachment;

@interface SHCFileManager : NSObject

+ (instancetype)sharedFileManager;
- (BOOL)decryptDataForAttachment:(SHCAttachment *)attachment;
- (BOOL)encryptDataForAttachment:(SHCAttachment *)attachment;
- (BOOL)removeAllDecryptedFiles;
- (BOOL)removeAllFiles;
- (NSString *)encryptedFilesFolderPath;
- (NSString *)decryptedFilesFolderPath;

@end
