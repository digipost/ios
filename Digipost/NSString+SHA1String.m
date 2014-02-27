//
//  NSString+SHA1String.m
//  Digipost
//
//  Created by Eivind Bohler on 02.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+SHA1String.h"

@implementation NSString (SHA1String)

- (NSString *)SHA1String
{
    // Kindly borrowed from http://stackoverflow.com/questions/6006743/getting-md5-and-sha-1

    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:strlen(cstr)];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (unsigned int)data.length, digest);

    NSMutableString *SHA1StringMutable = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [SHA1StringMutable appendFormat:@"%02x", digest[i]];
    }
    
    return [NSString stringWithString:SHA1StringMutable];
}

@end
