//
//  NSNumber+JsonParsing.m
//  Digipost
//
//  Created by Håkon Bogen on 30.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "NSNumber+JsonParsing.h"

@implementation NSNumber (JsonParsing)
+ (NSNumber *)nilOrValueForValue:(id)value
{
    return [value isKindOfClass:[NSNumber class]] ? value : @0;
}
@end
