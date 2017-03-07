//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "POSFileManager.h"
#import "NSString+SHA1String.h"
#import <RNCryptor_objc/RNEncryptor.h>
#import <RNCryptor_objc/RNDecryptor.h>
#import "POSOAuthManager.h"
#import "NSError+ExtraInfo.h"
#import "POSBaseEncryptedModel.h"
#import "Digipost-Swift.h"

// Custom NSError consts
NSString *const kFileManagerDecryptingErrorDomain = @"FileManagerDecryptingErrorDomain";
NSString *const kFileManagerEncryptingErrorDomain = @"FileManagerEncryptingErrorDomain";

NSString *const kFileManagerEncryptedFilesFolderName = @"encryptedFiles";
NSString *const kFileManagerDecryptedFilesFolderName = @"decryptedFiles";
NSString *const kFileManagerUploadsFolderName = @"uploads";

@implementation POSFileManager

#pragma mark - Public methods

+ (instancetype)sharedFileManager
{
    static POSFileManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[POSFileManager alloc] init];
    });

    return sharedInstance;
}

- (BOOL)decryptDataForBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel error:(NSError *__autoreleasing *)error
{
    POSAttachment *attachment = (id)baseEncryptionModel;

    OAuthToken *oauthToken = [OAuthToken oAuthTokenWithScope:[OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel]];

    NSString *password = oauthToken.password;

    if (password == nil || [password isEqualToString:NSString.string]) {

        //        DDLogError(@"Error: Can't decrypt data without a password");

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingNoPassword
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_NO_PASSWORD", @"No password") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    // First, ensure that we have the encrypted file
    NSString *encryptedFilePath = [baseEncryptionModel encryptedFilePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        //        DDLogError(@"Error: Can't decrypt data without an encrypted file at %@", encryptedFilePath);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingEncryptedFileNotFound
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_ENCRYPTED_FILE_NOT_FOUND", @"Encrypted file not found") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSError *localError = nil;
    NSData *encryptedFileData = [NSData dataWithContentsOfFile:encryptedFilePath
                                                       options:NSDataReadingMappedIfSafe
                                                         error:&localError];
    if (localError) {
        //        DDLogError(@"Error reading encrypted file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingErrorReadingEncryptedFile
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_ERROR_READING_ENCRYPTED_FILE", @"Error reading encrypted file") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }
    
    NSData *decryptedFileData = [RNDecryptor decryptData:encryptedFileData
                                        withPassword:password
                                               error:&localError];
    if (localError) {
        //        DDLogError(@"Error decrypting file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingDecryptionError
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_DECRYPTION_ERROR", @"Decryption error") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSString *decryptedFilePath = [baseEncryptionModel decryptedFilePath];

    // If we previously haven't done a proper cleanup job and the decrypted file still exists,
    // we need to manually remote it before writing a new one, to avoid NSFileManager throwing a tantrum
    if ([[NSFileManager defaultManager] fileExistsAtPath:decryptedFilePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:decryptedFilePath
                                                        error:&localError]) {
            //            DDLogError(@"Error removing decrypted file: %@", [localError localizedDescription]);

            if (error) {
                *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                             code:SHCFileManagerErrorCodeDecryptingRemovingDecryptedFile
                                         userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_REMOVING_DECRYPTED_FILE", @"Error removing decrypted file") }];
                (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
            }

            return NO;
        }
    }

    if (![decryptedFileData writeToFile:decryptedFilePath
                                options:NSDataWritingAtomic
                                  error:&localError]) {
        //        DDLogError(@"Error writing decrypted file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerDecryptingErrorDomain
                                         code:SHCFileManagerErrorCodeDecryptingWritingDecryptedFile
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_DECRYPT_ERROR_WRITING_DECRYPTED_FILE", @"Error writing decrypted file") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    return YES;
}

- (BOOL)encryptDataForBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel error:(NSError *__autoreleasing *)error
{
    POSAttachment *attachment = (id)baseEncryptionModel;
    NSString *password;
    if ([attachment isKindOfClass:[POSAttachment class]]) {
        OAuthToken *oauthToken = [OAuthToken highestOAuthTokenWithScope:[OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel]];
        password = [oauthToken password];

    } else {
        OAuthToken *oauthToken = [OAuthToken highestOAuthTokenWithScope:kOauth2ScopeFull];
        password = [oauthToken password];
    }
    if (!password) {
        //        DDLogError(@"Error: Can't encrypt data without a password");

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingNoPassword
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_NO_PASSWORD", @"No password") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    // First, ensure htat we have the decrypted file
    NSString *decryptedFilePath = [baseEncryptionModel decryptedFilePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:decryptedFilePath]) {
        //        DDLogError(@"Error: Can't encrypt data without a decrypted file at %@", decryptedFilePath);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingDecryptedFileNotFound
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_DECRYPTED_FILE_NOT_FOUND", @"Decrypted file not found") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSError *localError = nil;
    NSData *decryptedFileData = [NSData dataWithContentsOfFile:decryptedFilePath
                                                       options:NSDataReadingMappedIfSafe
                                                         error:&localError];
    if (localError) {
        //        DDLogError(@"Error reading decrypted file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingErrorReadingDecryptedFile
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_ERROR_READING_DECRYPTED_FILE", @"Error reading decrypted file") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }
    
    NSData *encryptedFileData = [RNEncryptor encryptData:decryptedFileData
                                        withSettings:kRNCryptorAES256Settings
                                            password:password
                                               error:&localError];

    if (localError) {
        //        DDLogError(@"Error encrypting file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingEncryptionError
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_ENCRYPTION_ERROR", @"Encryption error") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

        return NO;
    }

    NSString *encryptedFilePath = [baseEncryptionModel encryptedFilePath];

    // If we previously haven't done a proper cleanup job and the encrypted file still exists,
    // we need to manually remote it before writing a new one, to avoid NSFileManager throwing a tantrum
    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedFilePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:encryptedFilePath
                                                        error:&localError]) {
            //            DDLogError(@"Error removing encrypted file: %@", [localError localizedDescription]);

            if (error) {
                *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                             code:SHCFileManagerErrorCodeEncryptingRemovingEncryptedFile
                                         userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_REMOVING_ENCRYPTED_FILE", @"Error removing encrypted file") }];
                (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
            }

            return NO;
        }
    }

    if (![encryptedFileData writeToFile:encryptedFilePath
                                options:NSDataWritingAtomic
                                  error:&localError]) {
        //        DDLogError(@"Error writing encrypted file: %@", [localError localizedDescription]);

        if (error) {
            *error = [NSError errorWithDomain:kFileManagerEncryptingErrorDomain
                                         code:SHCFileManagerErrorCodeEncryptingWritingEncryptedFile
                                     userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"FILE_MANAGER_ENCRYPT_ERROR_WRITING_ENCRYPTED_FILE", @"Error writing decrypted file") }];
            (*error).errorTitle = NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
        }

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

- (BOOL)removeAllFilesInFolder:(NSString *)folder
{
    NSError *error = nil;
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder
                                                                             error:&error];
    if (error) {
        //        DDLogError(@"Error getting list of files: %@", [error localizedDescription]);
        return NO;
    } else {
        NSUInteger failures = 0;

        for (NSString *fileName in fileNames) {
            NSString *filePath = [folder stringByAppendingPathComponent:fileName];

            if (![[NSFileManager defaultManager] removeItemAtPath:filePath
                                                            error:&error]) {
                //                DDLogError(@"Error removing file: %@", [error localizedDescription]);
                failures++;
            }
        }

        if (failures > 0) {
            return NO;
        }
    }

    return YES;
}

- (NSString *)encryptedFilesFolderPath
{
    return [self folderPathWithFolderName:kFileManagerEncryptedFilesFolderName];
}

- (NSString *)decryptedFilesFolderPath
{
    return [self folderPathWithFolderName:kFileManagerDecryptedFilesFolderName];
}

- (NSString *)uploadsFolderPath
{
    return [self folderPathWithFolderName:kFileManagerUploadsFolderName];
}

- (NSString *)inboxFolderPath
{
    return [self folderPathWithFolderName:@"Inbox"];
}

#pragma mark - Private methods

- (NSString *)folderPathWithFolderName:(NSString *)folderName
{
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:folderName];

    BOOL isFolder = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath
                                             isDirectory:&isFolder]) {
        if (isFolder) {
            return folderPath;
        }
    }

    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
//        DDLogError(@"Error creating folder: %@", [error localizedDescription]);
        return nil;
    }

    return folderPath;
}

@end
