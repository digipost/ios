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
#import "GAI.h"
#import "POSDocumentsViewController.h"
#import "POSFoldersViewController.h"
#import "GAITracker.h"
#import "GAIFields.h"
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

//@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) id<GAITracker> googleAnalyticsTracker;

//GCM
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, strong) NSString* registrationToken;
@property(nonatomic, strong) NSDate* notificationReceived;

@end

@implementation SHCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-500, -500) forBarMetrics:UIBarMetricsDefault];
    
    [self deletePossibleOldTokensIfFirstRun];
    [self setupGoogleAnalytics];
        
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [SHCAppDelegate setupAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUploading:) name:kStartUploadingDocumentNotitification object:nil];
    [InvoiceBankAgreement updateActiveBankAgreementStatus];
    
    return YES;
}

- (BOOL)GCMTokenExist {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"GCMToken"];
    fetchRequest.resultType = NSDictionaryResultType;
    NSError *error = nil;
    NSArray *results = [[POSModelManager sharedManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (results.count > 0){
        return TRUE;
    }

    return FALSE;
}

- (void)storeGCMToken: (NSString*) token {
    [[POSModelManager sharedManager] deleteAllGCMTokens];
    GCMToken *gcmtoken = [NSEntityDescription insertNewObjectForEntityForName:@"GCMToken" inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    gcmtoken.token = token;
    NSError *error;

    [[POSModelManager sharedManager].managedObjectContext save:&error];
}

- (void)initGCM {
    if([self GCMTokenExist] == NO){
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

    NSTimeInterval elapsedTimeSinceLastNotification = [[NSDate date] timeIntervalSinceDate:_notificationReceived];
    
    if(elapsedTimeSinceLastNotification > 0 && elapsedTimeSinceLastNotification < 900.0f){
        _notificationReceived = NULL;
        [self submitAppLaunchGAEvent: @"push"];
    }else{
        [self submitAppLaunchGAEvent: @"normal"];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    [self GAEventLaunchType];
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
        } else {
            _connectedToGCM = true;
        }
    }];
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
        } else {
            NSLog(@"Successfully deleted GCM token");
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

- (void)submitAppLaunchGAEvent: (NSString *)action {
    NSString *category = @"app-launch-origin";
    NSString *label = [NSString stringWithFormat:@"%@-%@", category, action];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
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
        
        //        // add account vc as second view controller in navigation controller
        //        UIViewController *loginViewController = topViewController;
        //        // for iphone root controller will be login controller
        //        if ([loginViewController isKindOfClass:[SHCLoginViewController class]]) {
        //            [newViewControllerArray addObject:loginViewController];
        //            accountViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
        //        } else if ([loginViewController isKindOfClass:[UploadMenuViewController class]]){
        //
        //            loginViewController = navController.viewControllers[0];
        //            if ([loginViewController isKindOfClass:[SHCLoginViewController class]]) {
        //                [newViewControllerArray addObject:loginViewController];
        //            }
        //
        //        }
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

- (void) deletePossibleOldTokensIfFirstRun {

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        [OAuthToken removeAllTokens];
        [OAuthToken removeRefreshToken];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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

- (void)setupGoogleAnalytics {
    [[[GAI sharedInstance] logger] setLogLevel:__GOOGLE_ANALYTICS_LOG_LEVEL__];
    self.googleAnalyticsTracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_ID];
    [self.googleAnalyticsTracker set:kGAIAnonymizeIp value:[@YES stringValue]];
    [GAI sharedInstance].dispatchInterval = 40.0;
}

@end
