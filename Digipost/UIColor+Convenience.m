//
//  UIColor+Convenience.m
//  Digipost
//
//  Created by Håkon Bogen on 27.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "UIColor+Convenience.h"

@implementation UIColor (Convenience)
+ (UIColor *)pos_colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b
{
    return [UIColor colorWithRed:r / 255.0
                           green:g / 255.0
                            blue:b / 255.0
                           alpha:1.0f];
}
@end
