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
#import "POSNotice.h"

// Core Data model entity names
extern NSString *const kRootResourceEntityName;

@class POSMailbox;

@interface POSRootResource : NSManagedObject

// Attributes
@property (strong, nonatomic) NSNumber *authenticationLevel;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *currentBankAccount;
@property (strong, nonatomic) NSString *currentBankAccountUri;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *logoutUri;
@property (strong, nonatomic) NSString *middleName;
@property (strong, nonatomic) NSNumber *numberOfCards;
@property (strong, nonatomic) NSNumber *numberOfCardsReadyForVerification;
@property (strong, nonatomic) NSNumber *numberOfReceiptsHiddenUntilVerification;
@property (strong, nonatomic) NSNumber *unreadItemsInInbox;
@property (strong, nonatomic) NSString *uploadDocumentUri;
@property (nonatomic, retain) NSString *selfUri;
// Relationships
@property (strong, nonatomic) NSSet *mailboxes;

/**
 *  Attribute not stored in core data, should only be shown when once.
 */
@property (nonatomic, strong) POSNotice *notice;

+ (instancetype)existingRootResourceInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)rootResourceWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)deleteAllRootResourcesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@interface POSRootResource (CoreDataGeneratedAccessors)

- (void)addMailboxesObject:(POSMailbox *)value;
- (void)removeMailboxesObject:(POSMailbox *)value;
- (void)addMailboxes:(NSSet *)values;
- (void)removeMailboxes:(NSSet *)values;

@end
