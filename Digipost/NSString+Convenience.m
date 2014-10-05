//
//  NSString+Convenience.m
//  Digipost
//
//  Created by Håkon Bogen on 03.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "NSString+Convenience.h"

@implementation NSString (Convenience)
+(NSString*)stringByAddingSpace:(NSString*)stringToAddSpace atIndex:(NSInteger)index{
    NSString *firstPart = [stringToAddSpace substringToIndex:index];
    NSString *secondPart = [stringToAddSpace substringFromIndex:index];
    NSString *returnedString = [NSString stringWithFormat:@"%@ %@",firstPart,secondPart];
    
    return returnedString;
}
@end
