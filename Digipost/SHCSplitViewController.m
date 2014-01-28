//
//  SHCSplitViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 28.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCSplitViewController.h"
#import "SHCOAuthManager.h"
#import "SHCLoginViewController.h"
#import "SHCLetterViewController.h"
#import "SHCAppDelegate.h"

@interface SHCSplitViewController ()

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

    UINavigationController *detailNavigationController = [self.viewControllers lastObject];
    if ([detailNavigationController isKindOfClass:[UINavigationController class]]) {
        SHCLetterViewController *letterViewController = (SHCLetterViewController *)detailNavigationController.topViewController;
        if ([letterViewController isKindOfClass:[SHCLetterViewController class]]) {
            self.delegate = letterViewController;

            SHCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            appDelegate.letterViewController = letterViewController;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![SHCOAuthManager sharedManager].refreshToken) {
        UINavigationController *loginNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:kLoginNavigationControllerIdentifier];
        [self presentViewController:loginNavigationController animated:NO completion:nil];
    }

    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)presentLoginViewController:(NSNotification *)notification
{
    [self performSegueWithIdentifier:kPresentLoginModallyIdentifier sender:nil];
}

@end
