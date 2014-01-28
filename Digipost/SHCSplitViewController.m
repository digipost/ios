//
//  SHCSplitViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 28.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCSplitViewController.h"
#import "SHCOAuthManager.h"
#import "SHCLoginViewController.h"

@interface SHCSplitViewController ()

@end

@implementation SHCSplitViewController

- (void)viewDidAppear:(BOOL)animated
{
    if (![SHCOAuthManager sharedManager].refreshToken) {
//        [self performSegueWithIdentifier:kPresentLoginModallyIdentifier sender:nil];
        UINavigationController *loginNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:kLoginNavigationControllerIdentifier];
        [self presentViewController:loginNavigationController animated:NO completion:nil];
    }

    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
