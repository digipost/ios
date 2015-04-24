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

#import "UIViewController+BackButton.h"

@implementation UIViewController (BackButton)

- (void)setMenuButton
{
    return;
    [self setTitle:@"backButton"];
    //    [self.navigationItem setLeftBarButtonItem:backButton];
}

- (void)pos_setDefaultBackButton
{
    return;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(pos_popViewController)];
    [backButton setImageInsets:UIEdgeInsetsMake(3, -8, 0, 0)];
    //    [self.navigationItem setLeftBarButtonItem:backButton];
    backButton.accessibilityLabel = NSLocalizedString(@"Accessability backbutton title", @"name of back button");
    backButton.accessibilityHint = NSLocalizedString(@"Accessability backbutton title", @"name of back button");
}

- (void)pos_popViewController
{
    NSAssert(self.navigationController != nil, @"no nav controller");
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)pos_hasBackButton
{
    if (self.navigationController.viewControllers.count > 1) {
        NSInteger count = self.navigationController.viewControllers.count;
        UIViewController *lastViewController = (id)self.navigationController.viewControllers[count - 2];
        if (lastViewController.navigationItem.backBarButtonItem != nil) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}
@end
