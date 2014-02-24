//
//  UIViewController+BackButton.m
//  Digipost
//
//  Created by Håkon Bogen on 18.02.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "UIViewController+BackButton.h"

@implementation UIViewController (BackButton)
- (void)setMenuButton
{
    UIBarButtonItem *backButton = self.navigationItem.backBarButtonItem;
    
    [backButton setImage:[UIImage imageNamed:@"icon-navbar-drawer"]];
    [self.navigationItem setBackBarButtonItem:backButton];
}
@end
