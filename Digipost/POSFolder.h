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
NSString *const kFolderEntityName;

// Hard-coded folder names that we'll use until all folders are made dynamic in the Digipost system
extern NSString *const kFolderInboxName;
extern NSString *const kFolderWorkAreaName;
extern NSString *const kFolderArchiveName;

@class POSDocument;
@class POSMailbox;

@interface POSFolder : NSManagedObject

// Attributes
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uri;

// Relationships
@property (strong, nonatomic) NSSet *documents;
@property (strong, nonatomic) POSMailbox *mailbox;

+ (instancetype)folderWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingFolderWithName:(NSString *)folderName mailboxDigipostAddress:(NSString *)mailboxDigipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSString *)displayName;
@end

@interface POSFolder (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(POSDocument *)value;
- (void)removeDocumentsObject:(POSDocument *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;

@end
