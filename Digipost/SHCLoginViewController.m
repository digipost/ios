//
//  SHCLoginViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCLoginViewController.h"
#import "SHCOAuthViewController.h"
#import "SHCFoldersViewController.h"
#import "SHCOAuthManager.h"

// Notification names
NSString *const kPopToLoginViewControllerNotificationName = @"PopToLoginViewControllerNotification";

// Google Analytics screen name
NSString *const kLoginViewControllerScreenName = @"Login";

@interface SHCLoginViewController () <SHCOAuthViewControllerDelegate>

@end

@implementation SHCLoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.screenName = kLoginViewControllerScreenName;

    @try {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToSelf:) name:kPopToLoginViewControllerNotificationName object:nil];
    }
    @catch (NSException *exception) {
        DDLogWarn(@"Caught an exception: %@", exception);
    }

    if ([SHCOAuthManager sharedManager].refreshToken) {
        SHCFoldersViewController *foldersViewController = [self.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];
        [self.navigationController pushViewController:foldersViewController animated:NO];
    }
}

- (void)dealloc
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kPopToLoginViewControllerNotificationName object:nil];
    }
    @catch (NSException *exception) {
        DDLogWarn(@"Caught an exception: %@", exception);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPresentOAuthModallyIdentifier]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SHCOAuthViewController *OAuthViewController = (SHCOAuthViewController *)navigationController.topViewController;
        OAuthViewController.delegate = self;
    }
}

#pragma mark - SHCOAuthViewControllerDelegate

- (void)OAuthViewControllerDidAuthenticate:(SHCOAuthViewController *)OAuthViewController
{
    [self performSegueWithIdentifier:kPushFoldersIdentifier sender:nil];
}

#pragma mark - IBActions

- (IBAction)didTapRegisterButton:(UIButton *)sender
{
    [self register];
}

- (IBAction)unwindToLoginViewController:(UIStoryboardSegue *)unwindSegue
{
}

#pragma mark - Private methods

- (void)register
{
    // TODO: open register page in Safari
}

- (void)popToSelf:(NSNotification *)notification
{
    [self.navigationController popToViewController:self animated:YES];
}

@end
