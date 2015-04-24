//
//  UIViewController+Additions.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "UIViewController+Additions.h"
#import "POSFoldersViewController.h"

@implementation UIViewController (Additions)
- (void)updateNavbar
{
}

- (void)popViewController
{
    NSAssert(self.navigationController != nil, @"no nav controller");
    [self.navigationController popViewControllerAnimated:YES];
}

@end
