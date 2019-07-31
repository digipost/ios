//
//  Code39.h
//  Code39Test
//
//  Created by Lin Patrick on 10/17/15.
// MIT https://github.com/bclin087/Simple-Code39-generator-for-iOS

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Code39 : NSObject

+ (UIImage *)code39ImageFromString:(NSString *)strSource Width:(CGFloat)barcodew Height:(CGFloat)barcodeh;

@end
