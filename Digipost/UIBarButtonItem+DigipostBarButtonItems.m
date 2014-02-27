//
//  UIBarButtonItem+DigipostBarButtonItems.m
//  Digipost
//
//  Created by Håkon Bogen on 24.02.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "UIBarButtonItem+DigipostBarButtonItems.h"

@implementation UIBarButtonItem (DigipostBarButtonItems)
+(UIBarButtonItem *)barButtonItemWithInfoImageForTarget:(id)target action:(SEL)action
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar-icon-info"]
                       landscapeImagePhone:[UIImage imageNamed:@"navbar-icon-info-iphone-landscape"]
                                     style:UIBarButtonItemStyleBordered
                                    target:target
                                    action:action];
    return barButtonItem;
}

+ (UIBarButtonItem*)barButtonItemWithActionImageForTarget: (id)target action: (SEL)action
{
   UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar-icon-action"]
                       landscapeImagePhone:[UIImage imageNamed:@"navbar-icon-action-iphone-landscape"]
                                     style:UIBarButtonItemStyleBordered
                                    target:target
                                    action:action];
    return barButtonItem;
}
@end
