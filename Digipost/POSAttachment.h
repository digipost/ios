//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
@property (nonatomic, retain) NSNumber *endToEndEncrypted;
@property (nonatomic, retain) NSNumber *userKeyEncrypted;
@property (nonatomic, retain) NSData *metadata;

+ (instancetype)attachmentWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingAttachmentWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

//+ (instancetype)updateExistingAttachmentWithUriFromDictionary:(NSDictionary*)attributesDictionary inManagedObjectContext:(NSManagedObjectContext*) managedobjectcontext;
+ (instancetype)updateExistingAttachmentWithUriFromDictionary:(NSDictionary *)attributesDictionary existingAttachment:(POSAttachment *)existingAttachment inManagedObjectContext:(NSManagedObjectContext *)managedObjectcontext;
@end
