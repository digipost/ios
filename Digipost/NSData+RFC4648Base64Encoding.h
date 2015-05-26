//
//  NSData+RFC4648Base64Encoding.h
//  Digipost
//
//  Created by Håkon Bogen on 26/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (RFC4648Base64Encoding)

- (NSString *)pos_urlSafeBase64EncodedString;

@end
