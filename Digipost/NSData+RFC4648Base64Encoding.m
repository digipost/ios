//
//  NSData+RFC4648Base64Encoding.m
//  Digipost
//
//  Created by Håkon Bogen on 26/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

#import "NSData+RFC4648Base64Encoding.h"

@implementation NSData (RFC4648Base64Encoding)

- (NSString *)pos_urlSafeBase64EncodedString;
{
    NSString *base64EncodedString = [self base64EncodedStringWithOptions:0];
    base64EncodedString = [base64EncodedString stringByReplacingOccurrencesOfString:@"+"
                                                                         withString:@"-"];
    base64EncodedString = [base64EncodedString stringByReplacingOccurrencesOfString:@"/"
                                                                         withString:@"_"];
    base64EncodedString = [base64EncodedString stringByReplacingOccurrencesOfString:@"="
                                                                         withString:@""];
    return base64EncodedString;
}

@end
