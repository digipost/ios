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
extern NSString *const kMailboxEntityName;

@class SHCFolder;
@class SHCReceipt;
@class SHCRootResource;

@interface SHCMailbox : NSManagedObject

// Attributes
@property (strong, nonatomic) NSString *digipostAddress;
@property (strong, nonatomic) NSNumber *owner;
@property (strong, nonatomic) NSString *receiptsUri;

// Relationships
@property (strong, nonatomic) NSSet *folders;
@property (strong, nonatomic) SHCRootResource *rootResource;

+ (instancetype)mailboxWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingMailboxWithDigipostAddress:(NSString *)digipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@interface SHCMailbox (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(SHCFolder *)value;
- (void)removeFoldersObject:(SHCFolder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

- (void)addReceiptsObject:(SHCReceipt *)value;
- (void)removeReceiptsObject:(SHCReceipt *)value;
- (void)addReceipts:(NSSet *)values;
- (void)removeReceipts:(NSSet *)values;

@end
