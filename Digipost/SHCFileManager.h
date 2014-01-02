//
//  SHCFileManager.h
//  Digipost
//
//  Created by Eivind Bohler on 02.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHCFileManager : NSObject

+ (instancetype)sharedFileManager;
- (NSData *)fileDataForUri:(NSString *)uri;
- (void)setFileData:(NSData *)fileData forUri:(NSString *)uri;

@end
