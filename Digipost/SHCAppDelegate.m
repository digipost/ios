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
#import "POSAPIManager.h"
#import "POSMailbox+Methods.h"
#import "POSLetterViewController.h"
#import "SHCLoginViewController.h"
#import "POSFileManager.h"
#import "oauth.h"
#import "Digipost-Swift.h"

NSString *kHasMovedOldOauthTokensKey = @"hasMovedOldOauthTokens";

@interface SHCAppDelegate ()

//@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) id<GAITracker> googleAnalyticsTracker;

@end

@implementation SHCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    //    [self setupHockeySDK];

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

        AccountViewController *accountViewController;
        if ([navController.viewControllers[0] isKindOfClass:[AccountViewController class]]) {
            accountViewController = navController.viewControllers[0];
        } else {
            accountViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
        }

        POSFoldersViewController *folderViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];
        POSDocumentsViewController *documentsViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:kDocumentsViewControllerIdentifier];

        NSMutableArray *newViewControllerArray = [NSMutableArray array];
        // add account vc as second view controller in navigation controller
        UIViewController *loginViewController = topViewController;
        // for iphone root controller will be login controller
        if ([loginViewController isKindOfClass:[SHCLoginViewController class]]) {
            [newViewControllerArray addObject:loginViewController];
            accountViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
        }
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
                                 animated:YES];
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
        [rootNavController.topViewController presentViewController:uploadNavigationController animated:YES
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
//
//- (void)setupHockeySDK
//{
//    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:__HOCKEY_BETA_IDENTIFIER__
//                                                         liveIdentifier:__HOCKEY_LIVE_IDENTIFIER__
//                                                               delegate:self];
//    [[BITHockeyManager sharedHockeyManager] startManager];
//    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
//}

//- (void)setupCocoaLumberjack
//{
//    // Enable Apple System Logger (log messages appear in the Console.app)
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
//
//    // Enable Xcode debugger console (TTY) logger
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//
//    // If you want nice colors in Xcode's debugger console,
//    // go to https://github.com/robbiehanson/XcodeColors and follow instructions
//    // on how to install the neccesary Xcode plugin.
//    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
//
//    // Enable logging to file
//    self.fileLogger = [[DDFileLogger alloc] init];
//    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
//    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//    [self.fileLogger rollLogFileWithCompletionBlock:^{
//        [DDLog addLogger:self.fileLogger];
//    }];
//}

- (void)setupGoogleAnalytics
{
    [[[GAI sharedInstance] logger] setLogLevel:__GOOGLE_ANALYTICS_LOG_LEVEL__];

    // Initialize tracker.
    self.googleAnalyticsTracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-46373710-1"];
    [GAI sharedInstance].dispatchInterval = 5.0;
}

@end
