//
//  NSError+ExtraInfo.m
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <objc/runtime.h>
#import "NSError+ExtraInfo.h"

static void *kErrorTitleContext = &kErrorTitleContext;
static void *kErrorOkButtonTitleContext = &kErrorOkButtonTitleContext;
static void *kErrorTapBlockContext = &kErrorTapBlockContext;

@implementation NSError (ExtraInfo)

#pragma mark - Properties

- (NSString *)errorTitle
{
    NSString *errorTitle = objc_getAssociatedObject(self, kErrorTitleContext);

    if (errorTitle) {
        return errorTitle;
    } else {
        return NSLocalizedString(@"GENERIC_ERROR_TITLE", @"Error");
    }
}

- (void)setErrorTitle:(NSString *)errorTitle
{
    objc_setAssociatedObject(self, kErrorTitleContext, errorTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)okButtonTitle
{
    NSString *okButtonTitle = objc_getAssociatedObject(self, kErrorOkButtonTitleContext);

    if (okButtonTitle) {
        return okButtonTitle;
    } else {
        return NSLocalizedString(@"GENERIC_OK_BUTTON_TITLE", @"OK");
    }
}

- (void)setOkButtonTitle:(NSString *)okButtonTitle
{
    objc_setAssociatedObject(self, kErrorOkButtonTitleContext, okButtonTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(UIAlertView *alertView, NSInteger buttonIndex))tapBlock
{
    void(^tapBlock)(UIAlertView *alertView, NSInteger buttonIndex) = objc_getAssociatedObject(self, kErrorTapBlockContext);

    return tapBlock;
}

- (void)setTapBlock:(void (^)(UIAlertView *, NSInteger))tapBlock
{
    objc_setAssociatedObject(self, kErrorTapBlockContext, tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
