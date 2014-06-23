//
//  POSNoRotationNavigationController.m
//  Digipost
//
//  Created by Håkon Bogen on 23.06.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSNoRotationNavigationController.h"

@interface POSNoRotationNavigationController ()

@end

@implementation POSNoRotationNavigationController

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
