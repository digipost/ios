//
//  SHCMailbox.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Core Data model entity names
extern NSString *const kMailboxEntityName;

@class SHCFolder;
@class SHCReceipt;
@class SHCRootResource;

@interface SHCMailbox : NSManagedObject

// Attributes
@property (strong, nonatomic) NSString *digipostAddress;
@property (strong, nonatomic) NSNumber *owner;
@property (strong, nonatomic) NSString *receiptsUri;

// Relationships
@property (strong, nonatomic) NSSet *folders;
@property (strong, nonatomic) SHCRootResource *rootResource;

+ (instancetype)mailboxWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingMailboxWithDigipostAddress:(NSString *)digipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@interface SHCMailbox (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(SHCFolder *)value;
- (void)removeFoldersObject:(SHCFolder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

- (void)addReceiptsObject:(SHCReceipt *)value;
- (void)removeReceiptsObject:(SHCReceipt *)value;
- (void)addReceipts:(NSSet *)values;
- (void)removeReceipts:(NSSet *)values;

@end
