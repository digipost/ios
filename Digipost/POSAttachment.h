//
//  POSAttachment.h
//  Digipost
//
//  Created by Håkon Bogen on 30.06.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "POSBaseEncryptedModel.h"

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

extern NSString *const kAuthenticationLevelIDPorten4;
extern NSString *const kAuthenticationLevelIDPorten3;
extern NSString *const kAuthenticationLevelTwoFactor;
extern NSString *const kAuthenticationLevelPassword;

@class POSDocument;
@class POSInvoice;

@interface POSAttachment : POSBaseEncryptedModel

@property (nonatomic, retain) NSString *authenticationLevel;
@property (nonatomic, retain) NSNumber *fileSize;
@property (nonatomic, retain) NSString *fileType;
@property (nonatomic, retain) NSNumber *mainDocument;
@property (nonatomic, retain) NSNumber *read;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *uri;
@property (nonatomic, retain) NSString *openingReceiptUri;
@property (nonatomic, retain) POSDocument *document;
@property (nonatomic, retain) POSInvoice *invoice;
@property (nonatomic, retain) NSString *origin;

+ (instancetype)attachmentWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingAttachmentWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

//+ (instancetype)updateExistingAttachmentWithUriFromDictionary:(NSDictionary*)attributesDictionary inManagedObjectContext:(NSManagedObjectContext*) managedobjectcontext;
+ (instancetype)updateExistingAttachmentWithUriFromDictionary:(NSDictionary *)attributesDictionary existingAttachment:(POSAttachment *)existingAttachment inManagedObjectContext:(NSManagedObjectContext *)managedObjectcontext;
@end
