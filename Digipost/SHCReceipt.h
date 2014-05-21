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

// Core Data model entity names
extern NSString *const kReceiptEntityName;

// API Keys
extern NSString *const kReceiptReceiptAPIKey;

@class SHCMailbox;

@interface SHCReceipt : SHCBaseEncryptedModel

// Attributes
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSString *card;
@property (strong, nonatomic) NSString *currency;
@property (strong, nonatomic) NSString *deleteUri;
@property (strong, nonatomic) NSString *franchiseName;
@property (strong, nonatomic) NSString *mailboxDigipostAddress;
@property (strong, nonatomic) NSString *receiptId;
@property (strong, nonatomic) NSString *storeName;
@property (strong, nonatomic) NSDate *timeOfPurchase;
@property (strong, nonatomic) NSString *uri;

// Relationships
@property (strong, nonatomic) SHCMailbox *mailbox;

+ (instancetype)receiptWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingReceiptWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)reconnectDanglingReceiptsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)deleteAllReceiptsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allReceiptsWithMailboxWithDigipostAddress:(NSString *)digipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSString *)stringForReceiptAmount:(NSNumber *)amount;

@end
