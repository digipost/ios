//
//  SHCLoginViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 09.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GAI.h>

// Storyboard identifiers (to enable programmatic storyboard instantiation)
extern NSString *const kLoginNavigationControllerIdentifier;
extern NSString *const kLoginViewControllerIdentifier;

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPresentLoginModallyIdentifier;

// Notification names
extern NSString *const kShowLoginViewControllerNotificationName;

@interface SHCLoginViewController : GAITrackedViewController

@end
