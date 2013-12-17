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

// Notification names
NSString *const kPopToLoginViewControllerNotificationName = @"PopToLoginViewControllerNotification";

// Google Analytics screen name
NSString *const kLoginViewControllerScreenName = @"Login";

@interface SHCLoginViewController () <SHCOAuthViewControllerDelegate>

@end

@implementation SHCLoginViewController

#pragma mark - NSObject

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.detailViewController = (SHCDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.screenName = kLoginViewControllerScreenName;

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

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
    [UIActionSheet showFromRect:sender.frame
                         inView:self.view
                       animated:YES
                      withTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_REGISTER_TITLE", @"Register title")
              cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
         destructiveButtonTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_REGISTER_OPEN_IN_SAFARI_TITLE", @"Open in Safari")
              otherButtonTitles:nil
                       tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                           if (buttonIndex == 0) {
                               NSURL *url = [NSURL URLWithString:@"https://www.digipost.no/app/registrering#/"];
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
