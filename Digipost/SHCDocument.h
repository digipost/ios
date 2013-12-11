//
//  SHCDocument.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHCAttachment;
@class SHCFolder;

@interface SHCDocument : NSManagedObject

// Attributes
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *creatorName;

// Relationships
@property (strong, nonatomic) NSSet *attachments;
@property (strong, nonatomic) SHCFolder *folder;

@end

@interface SHCDocument (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(SHCAttachment *)value;
- (void)removeAttachmentsObject:(SHCAttachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;

@end
