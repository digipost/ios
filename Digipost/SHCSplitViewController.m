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

#import "SHCSplitViewController.h"
#import "SHCOAuthManager.h"
#import "SHCLoginViewController.h"
#import "SHCLetterViewController.h"
#import "SHCAppDelegate.h"

@interface SHCSplitViewController ()

@property (weak, nonatomic, readonly) SHCLetterViewController *letterViewController;

@end

@implementation SHCSplitViewController

#pragma mark - NSObject

- (void)dealloc
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowLoginViewControllerNotificationName object:nil];
    }
    @catch (NSException *exception) {
        DDLogWarn(@"Caught an exception: %@", exception);
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    @try {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentLoginViewController:) name:kShowLoginViewControllerNotificationName object:nil];
    }
    @catch (NSException *exception) {
        DDLogWarn(@"Caught an exception: %@", exception);
    }

    SHCLetterViewController *letterViewController = self.letterViewController;
    if (letterViewController) {
        self.delegate = letterViewController;

        SHCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.letterViewController = letterViewController;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![SHCOAuthManager sharedManager].refreshToken) {
        [self presentLoginViewController];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (SHCLetterViewController *)letterViewController
{
    SHCLetterViewController *letterViewController = nil;

    UINavigationController *detailNavigationController = [self.viewControllers lastObject];
    if ([detailNavigationController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = detailNavigationController.topViewController;
        if ([topViewController isKindOfClass:[SHCLetterViewController class]]) {
            letterViewController = (SHCLetterViewController *)topViewController;
        }
    }

    return letterViewController;
}

#pragma mark - Private methods

- (void)presentLoginViewController:(NSNotification *)notification
{
    [self presentLoginViewController];
}

- (void)presentLoginViewController
{
       SHCLetterViewController *letterViewController = self.letterViewController;
    if (letterViewController) {
        [letterViewController.masterViewControllerPopoverController dismissPopoverAnimated:YES];
    }
    [self performSegueWithIdentifier:kPresentLoginModallyIdentifier sender:nil];
    
    
}
@end
