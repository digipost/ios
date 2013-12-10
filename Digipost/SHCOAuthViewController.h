//
//  SHCOAuthViewController.h
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kPresentOAuthModallyIdentifier;

@protocol SHCOAuthViewControllerDelegate;

@interface SHCOAuthViewController : UIViewController

@property (weak, nonatomic) id<SHCOAuthViewControllerDelegate> delegate;

@end

@protocol SHCOAuthViewControllerDelegate <NSObject>

@required

- (void)OAuthViewControllerDidAuthenticate:(SHCOAuthViewController *)OAuthViewController;

@end