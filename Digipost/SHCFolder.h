//
//  SHCFolder.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHCDocument;
@class SHCMailbox;

@interface SHCFolder : NSManagedObject

// Attributes
@property (strong, nonatomic) NSString *name;

// Relationships
@property (strong, nonatomic) NSSet *documents;
@property (strong, nonatomic) SHCMailbox *mailbox;

@end

@interface SHCFolder (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(SHCDocument *)value;
- (void)removeDocumentsObject:(SHCDocument *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;

@end
