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
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![SHCOAuthManager sharedManager].refreshToken) {
//        [self performSegueWithIdentifier:kPresentLoginModallyIdentifier sender:nil];
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
