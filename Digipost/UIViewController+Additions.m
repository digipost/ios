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
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(popViewController)];

    if ([self isKindOfClass:[POSFoldersViewController class]]) {
        self.navigationItem.backBarButtonItem = backBarButtonItem;
    }
}

- (void)popViewController
{
    NSAssert(self.navigationController != nil, @"no nav controller");
    [self.navigationController popViewControllerAnimated:YES];
}

@end
