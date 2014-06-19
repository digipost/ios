//
//  UIColor+Convenience.h
//  Digipost
//
//  Created by Håkon Bogen on 27.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Convenience)

+ (UIColor *)pos_colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b;
+ (UIColor *)pos_colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alpha;
@end
