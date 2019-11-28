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

#import "POSFolder+Methods.h"
#import "POSDocumentsViewController.h"
#import "POSFoldersViewController.h"
#import <UIAlertView_Blocks/UIAlertView+Blocks.h>
#import "POSModelManager.h"
#import "POSUploadViewController.h"
#import "SHCAppDelegate.h"
#import "POSMailbox+Methods.h"
#import "POSLetterViewController.h"
#import "SHCLoginViewController.h"
#import "POSFileManager.h"
#import "oauth.h"
#import <Google/CloudMessaging.h>
#import "Digipost-Swift.h"

@interface SHCAppDelegate ()

//GCM
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, strong) NSString* registrationToken;
@property(nonatomic, strong) NSDate* notificationReceived;
@property(nonatomic, strong) UIView *localAuthenticationOverlayView;


@end

@implementation SHCAppDelegate
BOOL addedLocalAuthenticationOverlay = FALSE;
BOOL showingLogoutModal = FALSE;
BOOL appIsActive = FALSE;
BOOL onGoingAuthentication = FALSE;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-500, 0) forBarMetrics:UIBarMetricsDefault];
    
    [AppVersionManager deleteOldTokensIfReinstall];
    [SHCAppDelegate setupAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUploading:) name:kStartUploadingDocumentNotitification object:nil];
    [InvoiceBankAgreement updateActiveBankAgreementStatus];
    [UserNotificationsUsage reportActivationState];
    return YES;
}

- (void)storeGCMToken: (NSString*) token {
    [[POSModelManager sharedManager] deleteAllGCMTokens];
    GCMToken *gcmtoken = [NSEntityDescription insertNewObjectForEntityForName:@"GCMToken" inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    gcmtoken.token = token;
    NSError *error;
    
    [[POSModelManager sharedManager].managedObjectContext save:&error];
}

- (void)initGCM {
    if(![[POSModelManager sharedManager] GCMTokensExist]){
        _registrationKey = @"onRegistrationCompleted";
        
        NSError* configureError;
        [[GGLContext sharedInstance] configureWithError:&configureError];
        
        NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
        _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
        
        GCMConfig *gcmConfig = [GCMConfig defaultConfig];
        gcmConfig.receiverDelegate = self;
        [[GCMService sharedInstance] startWithConfig:gcmConfig];
        
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        __weak typeof(self) weakSelf = self;
        
        _registrationHandler = ^(NSString *registrationToken, NSError *error){
            if (registrationToken != nil) {
                weakSelf.registrationToken = registrationToken;
                
                [[APIClient sharedClient] registerGCMToken:(NSString *)registrationToken
                                                   success:^{
                                                       [weakSelf storeGCMToken: registrationToken];
                                                   } failure:^(APIError *error){
                                                   }
                 ];
                
                NSDictionary *userInfo = @{@"registrationToken":registrationToken};
                [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                    object:nil
                                                                  userInfo:userInfo];
            } else {
                NSDictionary *userInfo = @{@"error":error.localizedDescription};
                [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        };
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    
#ifdef STAGING
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@YES};
#else
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@NO};
#endif
    
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}

- (void)GAEventLaunchType {
    NSString *action = @"";
    
    NSTimeInterval elapsedTimeSinceLastNotification = [[NSDate date] timeIntervalSinceDate:_notificationReceived];
    if(elapsedTimeSinceLastNotification > 0 && elapsedTimeSinceLastNotification < 900.0f){
        _notificationReceived = NULL;
        action = @"push";
    }else{
        action = @"normal";
    }
    
    NSString *category = @"app-launch-origin";
    NSString *label = [NSString stringWithFormat:@"%@-%@", category, action];
    [GAEvents eventWithCategory:category action:action label:label value:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self GAEventLaunchType];
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
        } else {
            self->_connectedToGCM = true;
        }
    }];
    
    if(![LAStore devicePasscodeMinimumSet]){
        [self showSetupLocalAuthenticationModal];
    }else if(!appIsActive && [OAuthToken isUserLoggedIn] && !onGoingAuthentication){
        [self checkLocalAuthentication];
    }else if ([OAuthToken isUserLoggedIn] && !showingLogoutModal) {
        [self checkLocalAuthentication];
    }else if(![OAuthToken isUserLoggedIn]) {
        [self removeAuthOverlayView];
    }
}

-(void)userCanceledLocalAuthentication {
    [[APIClient sharedClient] logoutThenDeleteAllStoredData];
    [self showLoginView];
    [self removeAuthOverlayView];
}

-(void) showLogoutModal {
    showingLogoutModal = TRUE;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You sure you want to sign out?") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: @"Sign out")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              showingLogoutModal = FALSE;
                                                              onGoingAuthentication = FALSE;
                                                              [self userCanceledLocalAuthentication];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", comment: @"Cancel")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              showingLogoutModal = FALSE;
                                                              onGoingAuthentication = FALSE;
                                                              [self checkLocalAuthentication];
                                                          }]];
        [(id)self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}

-(void) setLocalReAuthenticationTimer {
    [self addAuthOverlayView];
    [LAStore saveAuthenticationTimeoutWithTimestamp: [[NSDate date] timeIntervalSince1970]];
}

-(void) deleteLocalAuthenticationState {
    [LAStore deleteAuthenticationAndTimestamp];
}

-(void) checkLocalAuthentication {
    [self addAuthOverlayView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLocalReAuthenticationTimer) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteLocalAuthenticationState) name:UIApplicationWillTerminateNotification object:nil];
    onGoingAuthentication = TRUE;
    
    if(![LAStore isValidAuthenticationAndTimestamp] || ([LAStore isValidAuthenticationAndTimestamp] && !appIsActive)){
        [LAStore authenticateUserWithCompletion:^(BOOL success, NSString* errorText, BOOL userCancel) {
            if(success){
                appIsActive = TRUE;
                onGoingAuthentication = FALSE;
                [self removeAuthOverlayView];
            }else{
                if(userCancel){
                    [self showLogoutModal];
                }else if([errorText isEqualToString:@"Passcode not set"]){
                        [self showSetupLocalAuthenticationModal];
                }
            }
        }];
    }else{
        //Success
        [self removeAuthOverlayView];
        onGoingAuthentication = FALSE;
    }
}

-(void)showSetupLocalAuthenticationModal {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SETUP_LOCALAUTH_PIN_HEADER", comment: "PIN/TouchID/FaceID er påkrevd for å bruke appen. Vennligst skru på dette i innstillinger") message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SETUP_LOCALAUTH_SETTINGS_LINK", comment: @"Åpne innstillinger")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                          onGoingAuthentication = FALSE;
                                                      }]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (id)self.window.rootViewController;
        UINavigationController *leftSideNavController = (id)splitViewController.viewControllers[0];
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.sourceView = leftSideNavController.topViewController.view;
        [leftSideNavController.topViewController presentViewController:alertController animated:YES completion:nil];
    }else{
        UINavigationController *rootNavController = (id)self.window.rootViewController;
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.sourceView = rootNavController.topViewController.view;
        [rootNavController.topViewController presentViewController:alertController animated:YES completion:nil];
    }
}

-(void) addAuthOverlayView {
    if(!addedLocalAuthenticationOverlay){
        addedLocalAuthenticationOverlay = TRUE;
        _localAuthenticationOverlayView = [[UIView alloc] initWithFrame:self.window.frame];
        _localAuthenticationOverlayView.backgroundColor = [UIColor whiteColor];
        [self.window.rootViewController.view addSubview:_localAuthenticationOverlayView];
    }
}

-(void) removeAuthOverlayView {
    addedLocalAuthenticationOverlay = FALSE;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.localAuthenticationOverlayView removeFromSuperview];
    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[POSFileManager sharedFileManager] removeAllDecryptedFiles];
    [[GCMService sharedInstance] disconnect];
    _connectedToGCM = NO;
    
}

- (void)onTokenRefresh {
    [[POSModelManager sharedManager] deleteAllGCMTokens];
    [self initGCM];
}

- (void)revokeGCMToken {
    GGLInstanceIDDeleteTokenHandler handler = ^void(NSError *error) {
        if (error) {
            NSLog(@"Failed to delete GCM token");
            [[POSModelManager sharedManager] deleteAllGCMTokens];
        } else {
            NSLog(@"Successfully deleted GCM token");
            [[POSModelManager sharedManager] deleteAllGCMTokens];
        }
    };
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    
    [[GGLInstanceID sharedInstance] deleteTokenWithAuthorizedEntity:_gcmSenderID scope:kGGLInstanceIDScopeGCM handler:handler];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    _notificationReceived = [NSDate date];
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void) showLoginView
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        UINavigationController *navController = [self.window topMasterNavigationController];
        NSMutableArray *newViewControllerArray = [NSMutableArray array];
        if ([navController.viewControllers[0] isKindOfClass:[SHCLoginViewController class]]) {
            SHCLoginViewController *loginViewController = navController.viewControllers[0];
            loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [newViewControllerArray addObject:loginViewController];
            dispatch_async(dispatch_get_main_queue(), ^{
                [navController setViewControllers:newViewControllerArray animated:YES];
            });
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewControllerNotificationName object:nil];
    }
}

- (void)startUploading:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    if ([self.window hasCorrectNavigationHierarchyForShowingDocuments]) {
        UINavigationController *navController = [self.window topMasterNavigationController];
        POSDocumentsViewController *documentsViewController = [navController documentsViewControllerInHierarchy];
        if (documentsViewController) {
            POSMailbox *mailbox = dict[@"mailbox"];
            POSFolder *folder = dict[@"folder"];
            NSAssert([mailbox isKindOfClass:[POSMailbox class]], @"not correct class");
            POSFoldersViewController *foldersViewController = [navController foldersViewControllerInHierarchy];
            foldersViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress;
            documentsViewController.folderName = folder.name;
            documentsViewController.mailboxDigipostAddress = mailbox.digipostAddress;
            documentsViewController.folderUri = folder.uri;
            documentsViewController.folderDisplayName = folder.displayName;
        }
        return;
    }
    if (dict[@"mailbox"]) {
        
        UINavigationController *navController = [self.window topMasterNavigationController];
        
        UIViewController *topViewController = [self.window topMasterViewController];
        [navController popToRootViewControllerAnimated:NO];
        
        NSMutableArray *newViewControllerArray = [NSMutableArray array];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            if ([navController.viewControllers[0] isKindOfClass:[SHCLoginViewController class]]) {
                SHCLoginViewController *loginViewController = navController.viewControllers[0];
                [newViewControllerArray addObject:loginViewController];
            }
        }
        
        AccountViewController *accountViewController;
        if ([navController.viewControllers[0] isKindOfClass:[AccountViewController class]]) {
            accountViewController = navController.viewControllers[0];
        } else {
            accountViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
        }
        
        POSFoldersViewController *folderViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];
        POSDocumentsViewController *documentsViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:kDocumentsViewControllerIdentifier];
        [newViewControllerArray addObject:accountViewController];
        [newViewControllerArray addObject:folderViewController];
        [newViewControllerArray addObject:documentsViewController];
        
        POSMailbox *mailbox = dict[@"mailbox"];
        POSFolder *folder = dict[@"folder"];
        
        NSAssert([mailbox isKindOfClass:[POSMailbox class]], @"not correct class");
        
        folderViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress;
        documentsViewController.folderName = folder.name;
        documentsViewController.mailboxDigipostAddress = mailbox.digipostAddress;
        documentsViewController.folderUri = folder.uri;
        documentsViewController.folderDisplayName = folder.displayName;
        
        [navController setViewControllers:newViewControllerArray
                                 animated:NO];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[POSFileManager sharedFileManager] removeAllDecryptedFiles];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [self uploadImageWithURL:url];
    return YES;
}

- (void)uploadImageWithURL:(NSURL *)url {
    UIStoryboard *storyboard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    UINavigationController *uploadNavigationController = (id)[storyboard instantiateViewControllerWithIdentifier:@"uploadNavigationController"];
    
    POSUploadViewController *uploadViewController = (id)uploadNavigationController.topViewController;
    uploadViewController.url = url;
    NSInteger numberOfMailboxes = [POSMailbox numberOfMailboxesStoredInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    if (numberOfMailboxes == 1) {
        uploadViewController.isShowingFolders = YES;
    }
    
    UINavigationController *rootNavController = (id)self.window.rootViewController;
    if ([rootNavController isKindOfClass:[UINavigationController class]]) {
        [rootNavController.topViewController presentViewController:uploadNavigationController
                                                          animated:YES
                                                        completion:^{
                                                        }];
    } else {
        UISplitViewController *splitViewController = (id)rootNavController;
        UINavigationController *leftSideNavController = (id)splitViewController.viewControllers[0];
        uploadNavigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [leftSideNavController.topViewController presentViewController:uploadNavigationController animated:YES completion:nil];
    }
}
#pragma mark - Private methods


@end
