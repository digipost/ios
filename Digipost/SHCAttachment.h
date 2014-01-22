//
//  SHCAttachment.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SHCBaseEncryptedModel.h"

// Custom NSError code enum
typedef NS_ENUM(NSUInteger, SHCAttachmentOpeningValidationErrorCode) {
    SHCAttachmentOpeningValidationErrorCodeWrongAuthenticationLevel = 1,
    SHCAttachmentOpeningValidationErrorCodeNoAttachmentUri
};

// Defines what the app considers a valid attachment authentication level
extern NSString *const kAttachmentOpeningValidAuthenticationLevel;

// Custom NSError consts
extern NSString *const kAttachmentOpeningValidationErrorDomain;

// Core Data model entity names
extern NSString *const kAttachmentEntityName;

@class SHCDocument;
@class SHCInvoice;

@interface SHCAttachment : SHCBaseEncryptedModel

// Attributes
@property (strong, nonatomic) NSString *authenticationLevel;
@property (strong, nonatomic) NSNumber *fileSize;
@property (strong, nonatomic) NSString *fileType;
@property (strong, nonatomic) NSNumber *mainDocument;
@property (strong, nonatomic) NSNumber *read;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *uri;

// Relationships
@property (strong, nonatomic) SHCDocument *document;
@property (strong, nonatomic) SHCInvoice *invoice;

+ (instancetype)attachmentWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingAttachmentWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
