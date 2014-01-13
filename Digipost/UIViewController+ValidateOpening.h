//
//  UIViewController+ValidateOpening.h
//  Digipost
//
//  Created by Eivind Bohler on 13.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHCAttachment;

@interface UIViewController (ValidateOpening)

- (void)validateOpeningAttachment:(SHCAttachment *)attachment success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
