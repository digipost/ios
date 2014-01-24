//
//  NSString+RandomNumber.m
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "NSString+RandomNumber.h"

@implementation NSString (RandomNumber)

+ (NSString *)randomNumberString
{
    return [NSString stringWithFormat:@"%u", arc4random() % UINT32_MAX];
}

@end
