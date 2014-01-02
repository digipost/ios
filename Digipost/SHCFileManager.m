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

- (NSData *)decryptedDataForAttachment:(SHCAttachment *)attachment
{
    NSData *decryptedData = nil;

    NSString *encryptedFilePath = [attachment encryptedFilePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {

        NSError *error = nil;
        NSData *encryptedFileData = [NSData dataWithContentsOfFile:encryptedFilePath options:NSDataReadingMappedIfSafe error:&error];

        if (error) {
            DDLogError(@"Error reading file: %@", [error localizedDescription]);
        } else {

            NSString *password = [SHCOAuthManager sharedManager].refreshToken;

            if (password) {
                decryptedData = [RNDecryptor decryptData:encryptedFileData
                                            withSettings:kRNCryptorAES256Settings
                                                password:password
                                                   error:&error];
                if (error) {
                    DDLogError(@"Error decrypting file: %@", [error localizedDescription]);
                }
            }
        }
    }

    return decryptedData;
}

- (BOOL)encryptDataForAttachment:(SHCAttachment *)attachment
{
    NSString *password = [SHCOAuthManager sharedManager].refreshToken;

    if (!password) {
        DDLogError(@"Error: Can't encrypt data for attachment without a password");
        return NO;
    }

    // First, check if we have the decrypted file data
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
    } else {

        NSString *encryptedFilePath = [attachment encryptedFilePath];

        // If we previously haven't done a proper cleanup job and the file still exists,
        // we need to manually remote it before writing a new one, to avoid NSFileManager throwing a tantrum
        if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:encryptedFilePath error:&error]) {
                DDLogError(@"Error removing file: %@", [error localizedDescription]);
                return NO;
            }
        }

        error = nil;
        if (![encryptedFileData writeToFile:encryptedFilePath options:NSDataWritingAtomic error:&error]) {
            DDLogError(@"Error writing to file: %@", [error localizedDescription]);
            return NO;
        }
    }

    // Last, but not least - let's remove the decrypted file
    if ([[NSFileManager defaultManager] fileExistsAtPath:decryptedFilePath]) {
        error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:decryptedFilePath error:&error]) {
            DDLogError(@"Error removing file: %@", [error localizedDescription]);
        }
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
    NSString *filesFolderPath = [self encryptedFilesFolderPath];

    NSError *error = nil;
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filesFolderPath error:&error];
    if (error) {
        DDLogError(@"Error getting list of files: %@", [error localizedDescription]);
        return NO;
    } else {
        NSUInteger failures = 0;

        for (NSString *fileName in fileNames) {
            NSString *filePath = [filesFolderPath stringByAppendingPathComponent:fileName];

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
