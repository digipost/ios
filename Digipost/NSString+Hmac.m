//
//  NSString+Hmac.m
//  Digipost
//
//  Created by Håkon Bogen on 26/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

#import "NSString+Hmac.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "NSData+RFC4648Base64Encoding.h"

@implementation NSString (Hmac)

+ (NSString *)pos_hmacsha256:(NSString *)data secret:(NSString *)key
{
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    NSString *hash = [HMAC pos_urlSafeBase64EncodedString];
    return hash;
}


@end
