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

#import <Foundation/Foundation.h>

// Custom NSError code enum
typedef NS_ENUM(NSUInteger, SHCFileManagerErrorCodeDecrypting) {
    SHCFileManagerErrorCodeDecryptingNoPassword = 1,
    SHCFileManagerErrorCodeDecryptingEncryptedFileNotFound,
    SHCFileManagerErrorCodeDecryptingErrorReadingEncryptedFile,
    SHCFileManagerErrorCodeDecryptingDecryptionError,
    SHCFileManagerErrorCodeDecryptingRemovingDecryptedFile,
    SHCFileManagerErrorCodeDecryptingWritingDecryptedFile
};

typedef NS_ENUM(NSUInteger, SHCFileManagerErrorCodeEncrypting) {
    SHCFileManagerErrorCodeEncryptingNoPassword = 1,
    SHCFileManagerErrorCodeEncryptingDecryptedFileNotFound,
    SHCFileManagerErrorCodeEncryptingErrorReadingDecryptedFile,
    SHCFileManagerErrorCodeEncryptingEncryptionError,
    SHCFileManagerErrorCodeEncryptingRemovingEncryptedFile,
    SHCFileManagerErrorCodeEncryptingWritingEncryptedFile
};

// Custom NSError consts
extern NSString *const kFileManagerDecryptingErrorDomain;
extern NSString *const kFileManagerEncryptingErrorDomain;

@class POSBaseEncryptedModel;

@interface POSFileManager : NSObject

+ (instancetype)sharedFileManager;
- (BOOL)decryptDataForBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel error:(NSError *__autoreleasing *)error;
- (BOOL)encryptDataForBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel error:(NSError *__autoreleasing *)error;
- (BOOL)removeAllDecryptedFiles;
- (BOOL)removeAllFiles;
- (BOOL)removeAllFilesInFolder:(NSString *)folder;
- (NSString *)encryptedFilesFolderPath;
- (NSString *)decryptedFilesFolderPath;
- (NSString *)uploadsFolderPath;
- (NSString *)inboxFolderPath;

@end
