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

NSString *kHasMovedOldOauthTokensKey = @"hasMovedOldOauthTokens";

@interface SHCAppDelegate ()

//@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) id<GAITracker> googleAnalyticsTracker;

//GCM
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, strong) NSString* registrationToken;

@end

@implementation SHCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-500, -500) forBarMetrics:UIBarMetricsDefault];
    
    [self checkForOldOAuthTokens];
    [self setupGoogleAnalytics];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [SHCAppDelegate setupAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUploading:) name:kStartUploadingDocumentNotitification object:nil];
    
    return YES;
}

//GCM Start

- (BOOL) GCMTokenExist{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"GCMToken"];
    fetchRequest.resultType = NSDictionaryResultType;
    NSError *error = nil;
    NSArray *results = [[POSModelManager sharedManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (results.count > 0){
        return TRUE;
    }

    return FALSE;
}

-(void)storeGCMToken: (NSString*) token {
    [[POSModelManager sharedManager] deleteAllGCMTokens];
    GCMToken *gcmtoken = [NSEntityDescription insertNewObjectForEntityForName:@"GCMToken" inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    gcmtoken.token = token;
    NSError *error;
    
    [[POSModelManager sharedManager].managedObjectContext save:&error];
}

- (void) initGCM{
    NSLog(@"GCMTokenExist %d", [self GCMTokenExist]);
    
    if([self GCMTokenExist] == NO){
    _registrationKey = @"onRegistrationCompleted";
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    
    // [START start_gcm_service]
    
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate = self;
    [[GCMService sharedInstance] startWithConfig:gcmConfig];
    
    // Register for remote notifications
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    __weak typeof(self) weakSelf = self;
    
    // Handler for registration token request
    _registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (registrationToken != nil) {
            weakSelf.registrationToken = registrationToken;
            
            [[APIClient sharedClient] registerGCMToken:(NSString *)registrationToken 
                                               success:^{
                                                   [weakSelf storeGCMToken: registrationToken];
                                                   NSLog(@"Token submit success!");
                                               } failure:^(APIError *error){
                                                   NSLog(@"Token submit failed!");
                                               }
             ];
            
            NSLog(@"Registration Token: %@", registrationToken);
            NSDictionary *userInfo = @{@"registrationToken":registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error":error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };
    }

}

// [START receive_apns_token]
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // [END receive_apns_token]
    // [START get_gcm_reg_token]
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@YES};
    
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}

// [START connect_gcm_service]
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Connect to the GCM server to receive non-APNS notifications
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
        } else {
            _connectedToGCM = true;
            NSLog(@"Connected to GCM");
        }
    }];
}
// [END connect_gcm_service]

// [START disconnect_gcm_service]
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[POSFileManager sharedFileManager] removeAllDecryptedFiles];
    
    [[GCMService sharedInstance] disconnect];
    _connectedToGCM = NO;
}
// [END disconnect_gcm_service]

// GCM [START on_token_refresh]
- (void)onTokenRefresh {
    NSLog(@"The GCM registration token needs to be changed.");
    [[POSModelManager sharedManager] deleteAllGCMTokens];
    [self initGCM];
}

-(void)revokeGCMToken{
        
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

//GCM END
- (void)startUploading:(NSNotification *)notification
{
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

- (void)applicationWillResignActive:(UIApplication *)application
{
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [[POSFileManager sharedFileManager] removeAllDecryptedFiles];
}

- (void)checkForOldOAuthTokens
{
    BOOL hasMovedOAuthtokens = [[NSUserDefaults standardUserDefaults] boolForKey:kHasMovedOldOauthTokensKey];
    if (hasMovedOAuthtokens == NO) {
        [OAuthToken moveOldOAuthTokensIfPresent];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasMovedOldOauthTokensKey];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self uploadImageWithURL:url];
    return YES;
}

- (void)uploadImageWithURL:(NSURL *)url
{
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

- (void)setupGoogleAnalytics
{
    [[[GAI sharedInstance] logger] setLogLevel:__GOOGLE_ANALYTICS_LOG_LEVEL__];
    self.googleAnalyticsTracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_ID];
    [self.googleAnalyticsTracker set:kGAIAnonymizeIp value:[@YES stringValue]];    
    [GAI sharedInstance].dispatchInterval = 40.0;
}

@end
