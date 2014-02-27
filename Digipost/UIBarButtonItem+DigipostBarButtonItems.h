//
//  UIBarButtonItem+DigipostBarButtonItems.h
//  Digipost
//
//  Created by Håkon Bogen on 24.02.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (DigipostBarButtonItems)

+(UIBarButtonItem *)barButtonItemWithInfoImageForTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem*)barButtonItemWithActionImageForTarget: (id)target action: (SEL)action;
@end
