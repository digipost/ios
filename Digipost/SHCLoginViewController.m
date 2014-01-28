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
#import "UIActionSheet+Blocks.h"
#import "SHCSplitViewController.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kLoginNavigationControllerIdentifier = @"LoginNavigationController";
NSString *const kLoginViewControllerIdentifier = @"LoginViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPresentLoginModallyIdentifier = @"PresentLoginModally";

// Notification names
NSString *const kPopToLoginViewControllerNotificationName = @"PopToLoginViewControllerNotification";

// Google Analytics screen name
NSString *const kLoginViewControllerScreenName = @"Login";

@interface SHCLoginViewController () <SHCOAuthViewControllerDelegate>

@end

@implementation SHCLoginViewController

- (void)dealloc
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kPopToLoginViewControllerNotificationName object:nil];
    }
    @catch (NSException *exception) {
        DDLogWarn(@"Caught an exception: %@", exception);
    }
}

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
        if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
            SHCFoldersViewController *foldersViewController = [self.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];
            [self.navigationController pushViewController:foldersViewController animated:NO];
        }
    }

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];
        self.navigationItem.backBarButtonItem = backBarButtonItem;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
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
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:kPushFoldersIdentifier sender:nil];
    }
}

#pragma mark - IBActions

- (IBAction)didTapRegisterButton:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:@"https://www.digipost.no/app/registrering#/"];

    [UIActionSheet showFromRect:sender.frame
                         inView:self.view
                       animated:YES
                      withTitle:[url host]
              cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
         destructiveButtonTitle:nil
              otherButtonTitles:@[NSLocalizedString(@"GENERIC_OPEN_IN_SAFARI_BUTTON_TITLE", @"Open in Safari")]
                       tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                           if (buttonIndex == 0) {
                               [[UIApplication sharedApplication] openURL:url];
                           }
                       }];
}

- (IBAction)unwindToLoginViewController:(UIStoryboardSegue *)unwindSegue
{
}

#pragma mark - Private methods

- (void)popToSelf:(NSNotification *)notification
{
    [self.navigationController popToViewController:self animated:YES];
}

@end
