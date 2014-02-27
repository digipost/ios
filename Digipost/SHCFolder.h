//
//  SHCFolder.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Core Data model entity names
NSString *const kFolderEntityName;

// Hard-coded folder names that we'll use until all folders are made dynamic in the Digipost system
extern NSString *const kFolderInboxName;
extern NSString *const kFolderWorkAreaName;
extern NSString *const kFolderArchiveName;

@class SHCDocument;
@class SHCMailbox;

@interface SHCFolder : NSManagedObject

// Attributes
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uri;

// Relationships
@property (strong, nonatomic) NSSet *documents;
@property (strong, nonatomic) SHCMailbox *mailbox;

+ (instancetype)folderWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingFolderWithName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSString * )displayName;
@end

@interface SHCFolder (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(SHCDocument *)value;
- (void)removeDocumentsObject:(SHCDocument *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;

@end
