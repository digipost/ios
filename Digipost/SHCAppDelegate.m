//
//  SHCAppDelegate.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <HockeySDK/HockeySDK.h>
#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
#import <GAI.h>
#import <GAITracker.h>
#import "SHCAppDelegate.h"
#import "SHCAPIManager.h"
#import "SHCLetterViewController.h"

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

    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:229.0/255.0 green:42.0/255.0 blue:19.0/255.0 alpha:1.0]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;

        UINavigationController *letterNavigationController = splitViewController.viewControllers[1];
        self.letterViewController = (SHCLetterViewController *)letterNavigationController.topViewController;
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark - Private methods

- (void)setupHockeySDK
{
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:__HOCKEY_BETA_IDENTIFIER__
                                                         liveIdentifier:__HOCKEY_LIVE_IDENTIFIER__
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
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
    [[SHCAPIManager sharedManager] startLogging];
}

- (void)setupGoogleAnalytics
{
    [[[GAI sharedInstance] logger] setLogLevel:__GOOGLE_ANALYTICS_LOG_LEVEL__];

    // Initialize tracker.
    self.googleAnalyticsTracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-46373710-1"];
    [GAI sharedInstance].dispatchInterval = 5.0;
}

@end
