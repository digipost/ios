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

#import "POSFolderIcon.h"

@implementation POSFolderIcon

+ (POSFolderIcon *)folderIconWithName:(NSString *)name
{
    POSFolderIcon *icon = [[POSFolderIcon alloc] init];
    icon.name = [name uppercaseString];
    return icon;
}

- (NSString *)upperCaseFirstLetterName
{
    NSString *lowercaseName = [_name lowercaseString];
    return [lowercaseName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                  withString:[[lowercaseName substringToIndex:1] uppercaseString]];
}

- (UIImage *)bigImage
{
    if (_bigImage == nil) {
        _bigImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [self upperCaseFirstLetterName]]];
    }
    return _bigImage;
}

- (UIImage *)bigSelectedImage
{
    if (_bigSelectedImage == nil) {
        _bigSelectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active", [self upperCaseFirstLetterName]]];
    }
    return _bigSelectedImage;
}

- (UIImage *)smallImage
{
    if (_smallImage == nil) {
        _smallImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_32", [self upperCaseFirstLetterName]]];
    }
    return _smallImage;
}

@end
