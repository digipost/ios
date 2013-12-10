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

@interface SHCLoginViewController () <SHCOAuthViewControllerDelegate>

@end

@implementation SHCLoginViewController

#pragma mark - UIViewController

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

@end
