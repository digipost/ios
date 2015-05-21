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
#import <UIAlertView_Blocks/UIAlertView+Blocks.h>
#import "POSModelManager.h"
#import "POSUploadViewController.h"
#import "SHCAppDelegate.h"
#import "POSMailbox+Methods.h"
#import "POSLetterViewController.h"
#import "SHCLoginViewController.h"
#import "POSFileManager.h"
#import "oauth.h"
#import "Digipost-Swift.h"
#import <HockeySDK/HockeySDK.h>

NSString *kHasMovedOldOauthTokensKey = @"hasMovedOldOauthTokens";

@interface SHCAppDelegate ()

//@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) id<GAITracker> googleAnalyticsTracker;

@end

@implementation SHCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self setupHockeySDK];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-500, -500) forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundVerticalPositionAdjustment:-400 forBarMetrics:UIBarMetricsDefault];
    //    [self setupCocoaLumberjack];
    [self checkForOldOAuthTokens];
    [self setupGoogleAnalytics];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [SHCAppDelegate setupAppearance];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUploading:) name:kStartUploadingDocumentNotitification object:nil];
    return YES;
}

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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[POSFileManager sharedFileManager] removeAllDecryptedFiles];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
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

- (void)setupHockeySDK
{

#if __IS_BETA__ == 0
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:__HOCKEY_LIVE_IDENTIFIER__];
#elif __IS_BETA__ == 1
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:__HOCKEY_BETA_IDENTIFIER__];
#else
#endif
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
}

- (void)setupGoogleAnalytics
{
    [[[GAI sharedInstance] logger] setLogLevel:__GOOGLE_ANALYTICS_LOG_LEVEL__];
    self.googleAnalyticsTracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_ID];
    [GAI sharedInstance].dispatchInterval = 40.0;
}

@end
