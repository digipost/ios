//
//  UIViewController+NeedsReload.m
//  Digipost
//
//  Created by Eivind Bohler on 07.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+NeedsReload.h"

static void *kNeedsReloadContext = &kNeedsReloadContext;

@implementation UIViewController (NeedsReload)

- (BOOL)needsReload
{
    NSNumber *needsReloadNumber = objc_getAssociatedObject(self, kNeedsReloadContext);

    BOOL needsReload = [needsReloadNumber boolValue];

    return needsReload;
}

- (void)setNeedsReload:(BOOL)needsReload
{
    objc_setAssociatedObject(self, kNeedsReloadContext, [NSNumber numberWithBool:needsReload], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
