//
//  SHCLoginViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCLoginViewController.h"

@interface SHCLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *loginTextField;

@end

@implementation SHCLoginViewController

#pragma mark - IBActions

- (IBAction)didTapLoginButton:(UIButton *)sender
{
    [self login];
}

#pragma mark - Private methods

- (void)login
{
}

@end
