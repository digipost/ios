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

@end
