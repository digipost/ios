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

#import <CommonCrypto/CommonDigest.h>
#import "NSString+SHA1String.h"

@implementation NSString (SHA1String)

- (NSString *)SHA1String
{
    // Kindly borrowed from http://stackoverflow.com/questions/6006743/getting-md5-and-sha-1

    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr
                                  length:strlen(cstr)];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (unsigned int)data.length, digest);

    NSMutableString *SHA1StringMutable = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [SHA1StringMutable appendFormat:@"%02x", digest[i]];
    }

    return [NSString stringWithString:SHA1StringMutable];
}

@end
