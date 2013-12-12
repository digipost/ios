//
//  SHCModelManager.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHCModelManager : NSObject

+ (instancetype)sharedManager;

- (void)updateModelsWithAttributes:(NSDictionary *)attributes;

@end
