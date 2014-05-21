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

// Core Data model entity names
extern NSString *const kInvoiceEntityName;

@class SHCAttachment;

@interface SHCInvoice : NSManagedObject

// Attributes
@property (strong, nonatomic) NSString *accountNumber;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *canBePaidByUser;
@property (strong, nonatomic) NSDate *dueDate;
@property (strong, nonatomic) NSString *kid;
@property (strong, nonatomic) NSString *sendToBankUri;
@property (strong, nonatomic) NSDate *timePaid;
@property (strong, nonatomic) NSString *bankHomepage;

// Relationships
@property (strong, nonatomic) SHCAttachment *attachment;

+ (instancetype)invoiceWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSString *)stringForInvoiceAmount:(NSNumber *)amount;
- (NSString *)statusDescriptionText;
@end
