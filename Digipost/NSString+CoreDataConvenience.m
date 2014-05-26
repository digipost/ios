//
//  NSString+CoreDataConvenience.m
//  Digipost
//
//  Created by Håkon Bogen on 26.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "NSString+CoreDataConvenience.h"

@implementation NSString (CoreDataConvenience)
+ (NSString *)nilOrValueForValue:(id)value
{
    return [value isKindOfClass:[NSString class]] ? value : nil;
}
@end
