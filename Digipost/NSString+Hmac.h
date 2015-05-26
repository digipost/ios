//
//  NSString+Hmac.h
//  Digipost
//
//  Created by Håkon Bogen on 26/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hmac)

+ (NSString *)pos_hmacsha256:(NSString *)data secret:(NSString *)key;

@end
