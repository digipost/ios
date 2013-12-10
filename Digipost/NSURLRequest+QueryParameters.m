//
//  NSURLRequest+QueryParameters.m
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "NSURLRequest+QueryParameters.h"

@implementation NSURLRequest (QueryParameters)

- (NSDictionary *)queryParameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    for (NSString *parameter in [[[self URL] query] componentsSeparatedByString:@"&"]) {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        if ([parts count] < 2) {
            continue;
        }

        parameters[[parts firstObject]] = parts[1];
    }

    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
