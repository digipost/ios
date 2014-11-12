//
//  AHKActionSheet+Convenience.h
//  Digipost
//
//  Created by Håkon Bogen on 03.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "AHKActionSheet.h"
#import "POSLetterViewController.h"

@interface AHKActionSheet (Convenience)

- (void)setupStyle;
+ (AHKActionSheet *)setupActionButtonsForLetterController:(POSLetterViewController *)letterViewController;

@end
