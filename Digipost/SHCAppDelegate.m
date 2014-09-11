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

#import <HockeySDK/HockeySDK.h>
#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
#import <GAI.h>
#import "POSDocumentsViewController.h"
#import "POSAccountViewController.h"
#import "POSFoldersViewController.h"
#import <GAITracker.h>
#import <UIAlertView+Blocks.h>
#import "POSUploadViewController.h"
#import "SHCAppDelegate.h"
#import "POSAPIManager.h"
#import "POSLetterViewController.h"
#import "POSFileManager.h"
#import "oauth.h"

@interface SHCAppDelegate () <BITHockeyManagerDelegate>

@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) id<GAITracker> googleAnalyticsTracker;

@end

@implementation SHCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self setupHockeySDK];

    [self setupCocoaLumberjack];

    [self setupNetworkingLogging];

    [self setupGoogleAnalytics];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:227.0 / 255.0
                                                                  green:45.0 / 255.0
                                                                   blue:34.0 / 255.0
                                                                  alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:1.0
                                                                 alpha:0.8]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUploading:) name:kStartUploadingDocumentNotitification object:nil];

    return YES;
}

- (void)startUploading:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    if (dict[@"mailbox"]) {
        UINavigationController *navController = (id)self.window.rootViewController;
        UIViewController *topViewController = navController.topViewController;
        [navController popToRootViewControllerAnimated:NO];
        POSAccountViewController *accountViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:kAccountViewControllerIdentifier];
        POSFoldersViewController *folderViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];
        POSDocumentsViewController *documentsViewController = [topViewController.storyboard instantiateViewControllerWithIdentifier:kDocumentsViewControllerIdentifier];

        NSMutableArray *newViewControllerArray = [NSMutableArray array];
        // add account vc as second view controller in navigation controller
        UIViewController *loginViewController = topViewController;

        [newViewControllerArray addObject:loginViewController];
        [newViewControllerArray addObject:accountViewController];
        [newViewControllerArray addObject:folderViewController];
        [newViewControllerArray addObject:documentsViewController];
        POSMailbox *mailbox = dict[@"mailbox"];
        POSFolder *folder = dict[@"folder"];

        NSAssert([mailbox isKindOfClass:[POSMailbox class]], @"not correct class");

        folderViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress;
        documentsViewController.folderName = folder.name;
        documentsViewController.mailboxDigipostAddress = mailbox.digipostAddress;

        [navController setViewControllers:newViewControllerArray
                                 animated:YES];

        if ([topViewController isKindOfClass:[POSDocumentsViewController class]]) {

        } else {
        }
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *uploadNavigationController = (id)[storyboard instantiateViewControllerWithIdentifier : @"uploadNavigationController"];
    POSUploadViewController *uploadViewController = (id)uploadNavigationController.topViewController;

    uploadViewController.url = url;

    UINavigationController *rootNavController = (id)self.window.rootViewController;
    [rootNavController.topViewController presentViewController:uploadNavigationController animated:YES
                                                    completion:^{}];
    return YES;
}

#pragma mark - Private methods

- (void)setupHockeySDK
{
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:__HOCKEY_BETA_IDENTIFIER__
                                                         liveIdentifier:__HOCKEY_LIVE_IDENTIFIER__
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
}

- (void)setupCocoaLumberjack
{
    // Enable Apple System Logger (log messages appear in the Console.app)
    [DDLog addLogger:[DDASLLogger sharedInstance]];

    // Enable Xcode debugger console (TTY) logger
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // If you want nice colors in Xcode's debugger console,
    // go to https://github.com/robbiehanson/XcodeColors and follow instructions
    // on how to install the neccesary Xcode plugin.
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];

    // Enable logging to file
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [self.fileLogger rollLogFileWithCompletionBlock:^{
        [DDLog addLogger:self.fileLogger];
    }];
}

- (void)setupNetworkingLogging
{
    [[POSAPIManager sharedManager] startLogging];
}

- (void)setupGoogleAnalytics
{
    [[[GAI sharedInstance] logger] setLogLevel:__GOOGLE_ANALYTICS_LOG_LEVEL__];

    // Initialize tracker.
    self.googleAnalyticsTracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-46373710-1"];
    [GAI sharedInstance].dispatchInterval = 5.0;
}

@end
