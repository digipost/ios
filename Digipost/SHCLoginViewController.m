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

#import "POSRootResource.h"
#import "POSFolder+Methods.h"
#import "POSDocumentsViewController.h"
#import "SHCLoginViewController.h"
#import "SHCOAuthViewController.h"
#import "POSModelManager.h"
#import "POSMailbox+Methods.h"
#import "POSFoldersViewController.h"
#import "POSOAuthManager.h"
#import "UIActionSheet+Blocks.h"
#import "SHCSplitViewController.h"
#import "digipost-Swift.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kLoginNavigationControllerIdentifier = @"LoginNavigationController";
NSString *const kLoginViewControllerIdentifier = @"LoginViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPresentLoginModallyIdentifier = @"PresentLoginModally";

// Notification names
NSString *const kShowLoginViewControllerNotificationName = @"ShowLoginViewControllerNotification";

// Google Analytics screen name
NSString *const kLoginViewControllerScreenName = @"Login";

@interface SHCLoginViewController () <SHCOAuthViewControllerDelegate, OnboardingLoginViewControllerDelegate, NewFeaturesViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIImageView *loginBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (strong, nonatomic) UIImageView *titleImageView;
@property (strong, nonatomic) IBOutlet UIButton *replayOnboardingButton;

@end

@implementation SHCLoginViewController

#pragma mark - NSObject

- (void)dealloc
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kShowLoginViewControllerNotificationName
                                                      object:nil];
    }
    @catch (NSException *exception)
    {
        //        DDLogWarn(@"Caught an exception: %@", exception);
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.loginButton.accessibilityLabel = @"Login";

    [self.replayOnboardingButton addTarget:self action:@selector(presentOnboarding) forControlEvents:UIControlEventTouchUpInside];

    self.screenName = kLoginViewControllerScreenName;

    @try {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(popToSelf:)
                                                     name:kShowLoginViewControllerNotificationName
                                                   object:nil];
    }
    @catch (NSException *exception)
    {
        //        DDLogWarn(@"Caught an exception: %@", exception);
    }

    [self.loginButton setTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_LOGIN_BUTTON_TITLE", @"Sign In")
                      forState:UIControlStateNormal];
    [self.registerButton setTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_REGISTER_BUTTON_TITLE", @"New user")
                         forState:UIControlStateNormal];
    [self.privacyButton setTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_PRIVACY_BUTOTN_TITLE", @"Privacy")
                        forState:UIControlStateNormal];

    if ([OAuthToken isUserLoggedIn]) {

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self presentAppropriateViewControllerForIPhone];
        }

        [Guide setOnboaringHasBeenWatched];

    } else {

        if ([Guide shouldShowOnboardingGuide]) {
            [self presentOnboarding];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationItem.rightBarButtonItem = nil;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
        self.navigationItem.backBarButtonItem = backBarButtonItem;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)presentOnboarding
{
    [self.loginView setHidden:YES];

    UIStoryboard *onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    __block OnboardingViewController *onboardingViewController = (id)[onboardingStoryboard instantiateInitialViewController];

    [self presentViewController:onboardingViewController animated:NO completion:^{
        onboardingViewController.onboardingLoginViewController.delegate = self;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPresentOAuthModallyIdentifier]) {
        SHCOAuthViewController *oAuthViewController;
        UINavigationController *navigationController = segue.destinationViewController;

        if ([navigationController isKindOfClass:[UINavigationController class]]) {
            oAuthViewController = (id)navigationController.topViewController;
        } else {
            oAuthViewController = (id)segue.destinationViewController;
        }
        oAuthViewController.delegate = self;
        oAuthViewController.scope = kOauth2ScopeFull;

        [self performSelector:@selector(showLoginButtonsIfHidden) withObject:nil afterDelay:0.5];
    }
}

- (void)showLoginButtonsIfHidden
{
    if ([self.loginView isHidden]) {
        [self.loginView setHidden:NO];
    }
}

- (void)presentNewFeatures
{
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        UIStoryboard *newFeaturesStoryboard = [UIStoryboard storyboardWithName:@"NewFeatures" bundle:nil];
        UINavigationController *navigationController = (id)[newFeaturesStoryboard instantiateInitialViewController];
        NewFeaturesViewController *newFeaturesController = (id)navigationController.viewControllers.firstObject;
        newFeaturesController.delegate = self;
        [self presentViewController:navigationController animated:NO completion:nil];
    }
}

#pragma mark - SHCOAuthViewControllerDelegate

- (void)OAuthViewControllerDidAuthenticate:(SHCOAuthViewController *)OAuthViewController scope:(NSString *)scope
{
    if ([Guide shouldShowWhatsNewGuide] && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [self presentNewFeatures];
    } else {

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

            [self.navigationController dismissViewControllerAnimated:YES
                                                          completion:^{

                                                          }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName
                                                                object:@NO];
        } else {
            [self presentAppropriateViewControllerForIPhone];
        }
    }
}

- (void)onboardingLoginViewControllerDidTapLoginButtonWithBackgroundImage:(OnboardingLoginViewController *)onboardingLoginViewController backgroundImage:(UIImage *)backgroundImage
{
    if (backgroundImage != nil) {
        self.loginBackgroundImageView.image = backgroundImage;
    }

    [onboardingLoginViewController.presentingViewController dismissViewControllerAnimated:NO completion:^{
        
        [self performSegueWithIdentifier:kPresentOAuthModallyIdentifier sender:self];

    }];
}

#pragma mark - NewFeatures dismiss controller delegate

- (void)newFeaturesViewControllerDidDismiss:(NewFeaturesViewController *)newFeaturesViewController
{
    [newFeaturesViewController dismissViewControllerAnimated:NO completion:^{
        [self.loginView setHidden:NO];
        [self presentAppropriateViewControllerForIPhone];
    }];
}

#pragma mark - IBActions

- (IBAction)didTapSecondaryButton:(UIButton *)sender
{
    NSURL *url;
    if (sender == self.registerButton) {
        url = [NSURL URLWithString:@"https://www.digipost.no/app/registrering#/"];
    }

    [UIActionSheet showFromRect:sender.frame
                         inView:[sender superview]
                       animated:YES
                      withTitle:[url host]
              cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
         destructiveButtonTitle:nil
              otherButtonTitles:@[ NSLocalizedString(@"GENERIC_OPEN_IN_SAFARI_BUTTON_TITLE", @"Open in Safari") ]
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

    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {

        [self.navigationController popToViewController:self
                                              animated:YES];
    }
}

- (void)presentAppropriateViewControllerForIPhone
{
    POSRootResource *resource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];

    if ([Guide shouldShowWhatsNewGuide]) {
        [self presentNewFeatures];
    } else if ([resource.mailboxes.allObjects count] == 1) {
        [self presentDocumentsViewControllerWithViewControllerStack];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    } else {
        [self performSegueWithIdentifier:@"accountSegue"
                                  sender:self];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)presentDocumentsViewControllerWithViewControllerStack
{
    // Instantiate view controllers for the navigation controller stack
    SHCLoginViewController *loginViewController = self;
    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
    POSFoldersViewController *foldersViewController = [self.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];

    POSDocumentsViewController *documentsViewController = [self.storyboard instantiateViewControllerWithIdentifier:kDocumentsViewControllerIdentifier];
    POSMailbox *mailbox = [POSMailbox mailboxOwnerInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    documentsViewController.folderName = kFolderInboxName;
    documentsViewController.mailboxDigipostAddress = mailbox.digipostAddress;

    // Add the view controllers to the stack
    NSMutableArray *viewControllerStack = [NSMutableArray array];
    [viewControllerStack addObject:loginViewController];
    [viewControllerStack addObject:accountViewController];
    [viewControllerStack addObject:foldersViewController];
    [viewControllerStack addObject:documentsViewController];

    // Set the new view controller stack for the navigation controller
    [self.navigationController setViewControllers:viewControllerStack animated:NO];
}

@end
