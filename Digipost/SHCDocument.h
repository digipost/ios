//
//  SHCDocument.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Core Data model entity names
extern NSString *const kDocumentEntityName;

// API keys
extern NSString *const kDocumentDocumentsAPIKey;

@class SHCAttachment;
@class SHCFolder;

@interface SHCDocument : NSManagedObject

// Attributes
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *creatorName;
@property (strong, nonatomic) NSString *deleteUri;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *updateUri;

// Relationships
@property (strong, nonatomic) NSSet *attachments;
@property (strong, nonatomic) SHCFolder *folder;

+ (instancetype)documentWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)reconnectDanglingDocumentsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allDocumentsInFolderWithName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (SHCAttachment *)mainDocumentAttachment;

@end

@interface SHCDocument (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(SHCAttachment *)value;
- (void)removeAttachmentsObject:(SHCAttachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;

@end
