//
//  NSPredicate+CommonPredicates.h
//  Digipost
//
//  Created by Håkon Bogen on 21.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (CommonPredicates)

+ (NSPredicate *)predicateWithDocumentsForSelectedMailBoxInFolderWithName:(NSString *)folderName;
+ (NSPredicate *)predicateWithDocumentsForMailBoxDigipostAddress: (NSString*)mailboxDigipostAddress inFolderWithName:(NSString *)folderName;
+ (NSPredicate *)predicateWithFoldersForSelectedMailBox;
+ (NSPredicate *)folderWithName:(NSString *)folderName mailboxDigipostAddressPredicate:(NSString *)mailboxDigipostAddress;

@end
