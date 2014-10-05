//
//  SHCDocumentsViewController+NavigationHierarchy.m
//  Digipost
//
//  Created by Håkon Bogen on 17.06.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "SHCDocumentsViewController+NavigationHierarchy.h"
#import "POSAccountViewController.h"
#import "POSFoldersViewController.h"

@implementation POSDocumentsViewController (NavigationHierarchy)
- (void)addAccountsAnFoldersVCToDoucmentHierarchy
{

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if ([self.navigationController.viewControllers[1] isKindOfClass:[POSAccountViewController class]] == NO) {
            POSAccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:kAccountViewControllerIdentifier];
            POSFoldersViewController *folderViewController = [self.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];

            NSMutableArray *newViewControllerArray = [NSMutableArray array];
            // add account vc as second view controller in navigation controller
            UIViewController *loginViewController = self.navigationController.viewControllers[0];

            POSDocumentsViewController *currentViewController = self.navigationController.viewControllers.lastObject;

            [newViewControllerArray addObject:loginViewController];
            [newViewControllerArray addObject:accountViewController];
            [newViewControllerArray addObject:folderViewController];
            [newViewControllerArray addObject:currentViewController];

            folderViewController.selectedMailBoxDigipostAdress = currentViewController.mailboxDigipostAddress;

            [self.navigationController setViewControllers:newViewControllerArray
                                                 animated:YES];
        }
    } else {
        if ([self.navigationController.viewControllers[1] isKindOfClass:[POSFoldersViewController class]] == NO) {
            POSFoldersViewController *folderViewController = [self.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];
            NSMutableArray *newViewControllerArray = [NSMutableArray array];
            // add account vc as second view controller in navigation controller
            POSAccountViewController *accountVC = self.navigationController.viewControllers[0];
            if ([accountVC isKindOfClass:[POSAccountViewController class]] == NO) {
                accountVC = [self.storyboard instantiateViewControllerWithIdentifier:kAccountViewControllerIdentifier];
            }

            POSDocumentsViewController *currentViewController = self.navigationController.viewControllers.lastObject;

            [newViewControllerArray addObject:accountVC];
            [newViewControllerArray addObject:folderViewController];
            [newViewControllerArray addObject:currentViewController];

            folderViewController.selectedMailBoxDigipostAdress = currentViewController.mailboxDigipostAddress;

            [self.navigationController setViewControllers:newViewControllerArray
                                                 animated:NO];
        }
    }
}
@end
