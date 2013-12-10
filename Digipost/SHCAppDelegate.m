//
//  SHCAppDelegate.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCAppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>

@interface SHCAppDelegate () <BITHockeyManagerDelegate>

@property (strong, nonatomic) DDFileLogger *fileLogger;

@end

@implementation SHCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupHockeySDK];

    [self setupCocoaLumberjack];

    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:229.0/255.0 green:42.0/255.0 blue:19.0/255.0 alpha:1.0]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

@end
