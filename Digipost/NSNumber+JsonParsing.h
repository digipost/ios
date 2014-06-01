//
//  NSNumber+JsonParsing.h
//  Digipost
//
//  Created by Håkon Bogen on 30.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (JsonParsing)

+ (NSNumber *)nilOrValueForValue:(id)value;
@end
