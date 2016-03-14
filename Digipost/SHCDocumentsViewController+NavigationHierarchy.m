//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "SHCDocumentsViewController+NavigationHierarchy.h"
#import "POSFoldersViewController.h"
#import "Digipost-Swift.h"

@implementation POSDocumentsViewController (NavigationHierarchy)
- (void)addAccountsAnFoldersVCToDoucmentHierarchy
{

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if ([self.navigationController.viewControllers[1] isKindOfClass:[AccountViewController class]] == NO) {
            AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
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
            AccountViewController *accountVC = self.navigationController.viewControllers[0];
            if ([accountVC isKindOfClass:[AccountViewController class]] == NO) {
                accountVC = [self.storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
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
