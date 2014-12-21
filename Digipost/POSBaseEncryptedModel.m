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

#import "POSBaseEncryptedModel.h"
#import "POSFileManager.h"
#import "POSModelManager.h"
#import "POSBaseEncryptedModel.h"
#import "NSString+SHA1String.h"

@interface POSBaseEncryptedModel ()

@property (nonatomic, strong) NSString *tempHumanReadablePathForFile;

@end

@implementation POSBaseEncryptedModel

@synthesize tempHumanReadablePathForFile;
@dynamic uri;
@dynamic fileType;

- (NSString *)encryptedFilePath
{
    NSString *fileName = [[self.uri SHA1String] stringByAppendingString:[NSString stringWithFormat:@".%@", self.fileType]];

    if (!fileName) {
        return nil;
    }

    NSString *filePath = [[[POSFileManager sharedFileManager] encryptedFilesFolderPath] stringByAppendingPathComponent:fileName];

    return filePath;
}

- (NSString *)decryptedFilePath
{
    NSString *fileName = [[self.uri SHA1String] stringByAppendingString:[NSString stringWithFormat:@".%@", self.fileType]];

    if (!fileName) {
        return nil;
    }

    NSString *filePath = [[[POSFileManager sharedFileManager] decryptedFilesFolderPath] stringByAppendingPathComponent:fileName];

    return filePath;
}

- (NSString *)humanReadablePathWithTitle:(NSString *)title
{
    NSError *error = nil;
    NSString *humanReadableURLString = [[[POSFileManager sharedFileManager] decryptedFilesFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", title, self.fileType]];
    [[NSFileManager defaultManager] copyItemAtPath:[self decryptedFilePath] toPath:humanReadableURLString error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    self.tempHumanReadablePathForFile = humanReadableURLString;
    return humanReadableURLString;
}

- (void)setTempHumanReadablePathForFile:(NSString *)tempHumanReadablePathForFile
{
    //    _tempHumanReadablePathForFile = tempHumanReadablePathForFile;
}

- (void)deletefileAtHumanReadablePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.tempHumanReadablePathForFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.tempHumanReadablePathForFile error:nil];
    }
}

- (void)deleteDecryptedFileIfExisting
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.decryptedFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.decryptedFilePath error:nil];
    }
}

- (void)deleteEncryptedFileIfExisting
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.encryptedFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.encryptedFilePath error:nil];
    }
}

@end
