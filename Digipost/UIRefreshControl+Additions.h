//
//  UIRefreshControl+Additions.h
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIRefreshControl (Additions)

- (void)updateRefreshControlTextRefreshing:(BOOL)refreshing;
- (void)initializeRefreshControlText;

@end
