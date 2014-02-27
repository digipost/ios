//
//  SHCAppDelegate.h
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHCLetterViewController;

@interface SHCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) SHCLetterViewController *letterViewController;

@end
