//
//  SHCMailbox.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHCFolder;
@class SHCRootResource;

@interface SHCMailbox : NSManagedObject

// Attributes
@property (strong, nonatomic) NSString *digipostAddress;
@property (strong, nonatomic) NSNumber *owner;

// Relationships
@property (strong, nonatomic) NSSet *folders;
@property (strong, nonatomic) SHCRootResource *rootResource;

+ (instancetype)mailboxWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@interface SHCMailbox (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(SHCFolder *)value;
- (void)removeFoldersObject:(SHCFolder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

@end
