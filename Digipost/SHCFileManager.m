//
//  SHCFileManager.m
//  Digipost
//
//  Created by Eivind Bohler on 02.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCFileManager.h"
#import "NSString+SHA1String.h"
#import <RNCryptor/RNEncryptor.h>
#import <RNCryptor/RNDecryptor.h>
#import "SHCOAuthManager.h"
#import "SHCAttachment.h"

NSString *const kFileManagerEncryptedFilesFolderName = @"encryptedFiles";
NSString *const kFileManagerDecryptedFilesFolderName = @"decryptedFiles";

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

- (BOOL)decryptDataForAttachment:(SHCAttachment *)attachment
{
    NSString *password = [SHCOAuthManager sharedManager].refreshToken;

    if (!password) {
        DDLogError(@"Error: Can't decrypt data for attachment without a password");
        return NO;
    }

    // First, ensure that we have the encrypted file
    NSString *encryptedFilePath = [attachment encryptedFilePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        DDLogError(@"Error: Can't decrypt data for attachment without an encrypted file at %@", encryptedFilePath);
        return NO;
    }

    NSError *error = nil;
    NSData *encryptedFileData = [NSData dataWithContentsOfFile:encryptedFilePath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        DDLogError(@"Error reading encrypted file: %@", [error localizedDescription]);
        return NO;
    }

    NSData *decryptedFileData = [RNDecryptor decryptData:encryptedFileData
                                            withSettings:kRNCryptorAES256Settings
                                                password:password
                                                   error:&error];
    if (error) {
        DDLogError(@"Error decrypting file: %@", [error localizedDescription]);
        return NO;
    }

    NSString *decryptedFilePath = [attachment decryptedFilePath];

    // If we previously haven't done a proper cleanup job and the decrypted file still exists,
    // we need to manually remote it before writing a new one, to avoid NSFileManager throwing a tantrum
    if ([[NSFileManager defaultManager] fileExistsAtPath:decryptedFilePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:decryptedFilePath error:&error]) {
            DDLogError(@"Error removing decrypted file: %@", [error localizedDescription]);
            return NO;
        }
    }

    if (![decryptedFileData writeToFile:decryptedFilePath options:NSDataWritingAtomic error:&error]) {
        DDLogError(@"Error writing decrypted file: %@", [error localizedDescription]);
        return NO;
    }

    return YES;
}

- (BOOL)encryptDataForAttachment:(SHCAttachment *)attachment
{
    NSString *password = [SHCOAuthManager sharedManager].refreshToken;

    if (!password) {
        DDLogError(@"Error: Can't encrypt data for attachment without a password");
        return NO;
    }

    // First, ensure htat we have the decrypted file
    NSString *decryptedFilePath = [attachment decryptedFilePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:decryptedFilePath]) {
        DDLogError(@"Error: Can't encrypt data for attachment without a decrypted file at %@", decryptedFilePath);
        return NO;
    }

    NSError *error = nil;
    NSData *decryptedFileData = [NSData dataWithContentsOfFile:decryptedFilePath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        DDLogError(@"Error reading decrypted file: %@", [error localizedDescription]);
        return NO;
    }

    NSData *encryptedFileData = [RNEncryptor encryptData:decryptedFileData
                                            withSettings:kRNCryptorAES256Settings
                                                password:password
                                                   error:&error];
    if (error) {
        DDLogError(@"Error encrypting file: %@", [error localizedDescription]);
        return NO;
    }

    NSString *encryptedFilePath = [attachment encryptedFilePath];

    // If we previously haven't done a proper cleanup job and the encrypted file still exists,
    // we need to manually remote it before writing a new one, to avoid NSFileManager throwing a tantrum
    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:encryptedFilePath error:&error]) {
            DDLogError(@"Error removing encrypted file: %@", [error localizedDescription]);
            return NO;
        }
    }

    error = nil;
    if (![encryptedFileData writeToFile:encryptedFilePath options:NSDataWritingAtomic error:&error]) {
        DDLogError(@"Error writing encrypted file: %@", [error localizedDescription]);
        return NO;
    }

    return YES;
}

- (BOOL)removeAllDecryptedFiles
{
    BOOL success = [self removeAllFilesInFolder:[self decryptedFilesFolderPath]];

    return success;
}

- (BOOL)removeAllFiles
{
    BOOL successfullyRemovedEncryptedFiles = [self removeAllFilesInFolder:[self encryptedFilesFolderPath]];
    BOOL successfullyRemovedDecryptedFiles = [self removeAllFilesInFolder:[self decryptedFilesFolderPath]];

    return successfullyRemovedEncryptedFiles && successfullyRemovedDecryptedFiles;
}

- (NSString *)encryptedFilesFolderPath
{
    return [self folderPathWithFolderName:kFileManagerEncryptedFilesFolderName];
}

- (NSString *)decryptedFilesFolderPath
{
    return [self folderPathWithFolderName:kFileManagerDecryptedFilesFolderName];
}

#pragma mark - Private methods

- (NSString *)folderPathWithFolderName:(NSString *)folderName
{
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:folderName];

    BOOL isFolder = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isFolder]) {
        if (isFolder) {
            return folderPath;
        }
    }

    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        DDLogError(@"Error creating folder: %@", [error localizedDescription]);
        return nil;
    }

    return folderPath;
}

- (BOOL)removeAllFilesInFolder:(NSString *)folder
{
    NSError *error = nil;
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:&error];
    if (error) {
        DDLogError(@"Error getting list of files: %@", [error localizedDescription]);
        return NO;
    } else {
        NSUInteger failures = 0;

        for (NSString *fileName in fileNames) {
            NSString *filePath = [folder stringByAppendingPathComponent:fileName];

            if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                DDLogError(@"Error removing file: %@", [error localizedDescription]);
                failures++;
            }
        }

        if (failures > 0) {
            return NO;
        }
    }
    
    return YES;
}

@end
