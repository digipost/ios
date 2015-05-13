//
//  POSFolder+Methods.h
//  Digipost
//
//  Created by Håkon Bogen on 21.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSFolder.h"
// Core Data model entity names
extern NSString *const kFolderEntityName;

// Hard-coded folder names that we'll use until all folders are made dynamic in the Digipost system
extern NSString *const kFolderInboxName;
extern NSString *const kFolderWorkAreaName;
extern NSString *const kFolderArchiveName;

@interface POSFolder (Methods)

+ (instancetype)pos_existingFolderWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)folderWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (instancetype)userMadeFolderWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (instancetype)existingFolderWithName:(NSString *)folderName mailboxDigipostAddress:(NSString *)mailboxDigipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)foldersForUserWithMailboxDigipostAddress:(NSString *)mailboxDigipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSString *)displayName;
- (NSString *)highestOAuth2ScopeForContainedDocuments;

@end
