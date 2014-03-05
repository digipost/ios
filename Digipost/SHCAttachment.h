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
