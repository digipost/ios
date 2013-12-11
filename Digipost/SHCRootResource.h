//
//  SHCRootResource.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHCMailbox;

@interface SHCRootResource : NSManagedObject

// Attributes
@property (strong, nonatomic) NSNumber *authenticationLevel;

// Relationships
@property (strong, nonatomic) NSSet *mailboxes;

@end

@interface SHCRootResource (CoreDataGeneratedAccessors)

- (void)addMailboxesObject:(SHCMailbox *)value;
- (void)removeMailboxesObject:(SHCMailbox *)value;
- (void)addMailboxes:(NSSet *)values;
- (void)removeMailboxes:(NSSet *)values;

@end
