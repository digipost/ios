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

NSString *const kFileManagerEncryptedFilesFolderName = @"encryptedFiles";

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

    NSString *fileName = [uri SHA1String];

    NSString *filePath = [[self encryptedFilesFolderPath] stringByAppendingPathComponent:fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {

        NSError *error = nil;
        NSData *encryptedFileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];

        if (error) {
            DDLogError(@"Error reading file: %@", [error localizedDescription]);
        } else {

            NSString *password = [SHCOAuthManager sharedManager].refreshToken;

            if (password) {
                fileData = [RNDecryptor decryptData:encryptedFileData
                                       withSettings:kRNCryptorAES256Settings
                                           password:password
                                              error:&error];
                if (error) {
                    DDLogError(@"Error decrypting file: %@", [error localizedDescription]);
                }
            }
        }
    }

    return fileData;
}

- (BOOL)setFileData:(NSData *)fileData forUri:(NSString *)uri
{
    NSString *password = [SHCOAuthManager sharedManager].refreshToken;

    if (!password) {
        return NO;
    }

    NSError *error = nil;
    NSData *encryptedFileData = [RNEncryptor encryptData:fileData
                                            withSettings:kRNCryptorAES256Settings
                                                password:password
                                                   error:&error];
    if (error) {
        DDLogError(@"Error encrypting file: %@", [error localizedDescription]);
        return NO;
    } else {
        NSString *fileName = [uri SHA1String];

        NSString *filePath = [[self encryptedFilesFolderPath] stringByAppendingPathComponent:fileName];

        // If we previously haven't done a proper cleanup job and the file still exists,
        // we need to manually remote it before writing a new one, to avoid NSFileManager throwing a tantrum
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                DDLogError(@"Error removing file: %@", [error localizedDescription]);
                return NO;
            }
        }

        error = nil;
        if (![encryptedFileData writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            DDLogError(@"Error writing to file: %@", [error localizedDescription]);
            return NO;
        }
    }

    return YES;
}

- (BOOL)removeAllFiles
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

#pragma mark - Private methods

- (NSString *)encryptedFilesFolderPath
{
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:kFileManagerEncryptedFilesFolderName];

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

@end
