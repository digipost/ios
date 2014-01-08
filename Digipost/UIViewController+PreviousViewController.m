//
//  UIViewController+PreviousViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 07.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "UIViewController+PreviousViewController.h"

@implementation UIViewController (PreviousViewController)

- (UIViewController *)previousViewController
{
    UIViewController *previousViewController = nil;

    NSUInteger indexOfThisViewController = [self.navigationController.viewControllers indexOfObject:self];
    NSUInteger indexOfPreviousViewController = indexOfThisViewController - 1;
    if (indexOfPreviousViewController > 0 && indexOfPreviousViewController < [self.navigationController.viewControllers count]) {

        previousViewController = self.navigationController.viewControllers[indexOfPreviousViewController];
    }

    return previousViewController;
}

@end
