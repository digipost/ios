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
#import "SHCSplitViewController.h"
#import "SHCAppDelegate.h"
#import "Digipost-Swift.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kLoginNavigationControllerIdentifier = @"LoginNavigationController";
NSString *const kLoginViewControllerIdentifier = @"LoginViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPresentLoginModallyIdentifier = @"PresentLoginModally";
NSString *const kRegistrationWebViewIdentifier = @"registrationWebView";
NSString *const kForgotPasswordWebViewIdentifier = @"forgotPasswordWebView";

// Notification names
NSString *const kShowLoginViewControllerNotificationName = @"ShowLoginViewControllerNotification";

@interface SHCLoginViewController () <SHCOAuthViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginIdPortenButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (strong, nonatomic) UIImageView *titleImageView;
@end

@interface SHCLoginViewController () <SFSafariViewControllerDelegate>
@end

@implementation SHCLoginViewController

#pragma mark - NSObject


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginButton.accessibilityLabel = @"Logg inn med fødselsnummer og passord";
    self.loginIdPortenButton.accessibilityLabel = @"Logg inn med elektronisk ID via ID-porten";
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if([OAuthToken isUserLoggedIn]){
            [self presentAppropriateViewControllerForIPhone];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPresentOAuthModallyIdentifier] || [segue.identifier isEqualToString:@"PresentOAuthIdPortenModally"]) {
        SHCOAuthViewController *oAuthViewController;
        UINavigationController *navigationController = segue.destinationViewController;
        
        if ([navigationController isKindOfClass:[UINavigationController class]]) {
            oAuthViewController = (id)navigationController.topViewController;
        } else {
            oAuthViewController = (id)segue.destinationViewController;
        }
        oAuthViewController.delegate = self;
        if([segue.identifier isEqualToString:kPresentOAuthModallyIdentifier]){
            oAuthViewController.scope = kOauth2ScopeFull;
        }else if([segue.identifier isEqualToString:@"PresentOAuthIdPortenModally"]){
            oAuthViewController.scope = kOauth2ScopeFull_Idporten3;
        }
    }else if ([segue.identifier isEqualToString:kRegistrationWebViewIdentifier]) {
        [self sendAnalyticsEvent:@"registrering"];
        
        SingleUseWebViewController *webView = (SingleUseWebViewController*) segue.destinationViewController;
        UINavigationController *navigationController = segue.destinationViewController;
        webView = (id)navigationController.topViewController;
        webView.viewTitle = NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_REGISTER_BUTTON_TITLE", "New user");
        webView.initUrl = @"https://www.digipost.no/app/registrering?utm_source=iOS_app&utm_medium=app&utm_campaign=app-link&utm_content=ny_bruker#/";
    }
}

#pragma mark - SHCOAuthViewControllerDelegate

- (void)OAuthViewControllerDidAuthenticate:(SHCOAuthViewController *)OAuthViewController scope:(NSString *)scope
{
    
    //successfull login
    //initialize gcm notification, if its not already existing.
    SHCAppDelegate *appDelegate = (id)[UIApplication sharedApplication].delegate;
    [appDelegate initGCM];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName
                                                            object:@NO];
    } else {
        [self presentAppropriateViewControllerForIPhone];
    }
    
    [InvoiceBankAgreement updateActiveBankAgreementStatus];
}

#pragma mark - IBActions

- (IBAction)didTapPrivacyButton:(UIButton *)sender
{
    [self sendAnalyticsEvent:@"personvern"];
    NSURL* url = [NSURL URLWithString:@"https://www.digipost.no/juridisk/#personvern"];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:url];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:NO completion:nil];
}

-(void) sendAnalyticsEvent: (NSString*) event {
    [GAEvents eventWithCategory:@"innlogging" action:@"klikk-link" label:event value:nil];
}

#pragma mark - Private methods

- (void)popToSelf:(NSNotification *)notification
{
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        
        [self.navigationController popToViewController:self
                                              animated:YES];
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            if ([userInfo[@"alert"] isMemberOfClass:[UIAlertController class]]) {
                UIAlertController *alertController = userInfo[@"alert"];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

- (void)presentAppropriateViewControllerForIPhone
{
    POSRootResource *resource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    
    if ([resource.mailboxes.allObjects count] == 1) {
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController setViewControllers:viewControllerStack animated:NO];
    });
}

@end
