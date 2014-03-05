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
