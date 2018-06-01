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
#import "POSFolder.h"

@class POSMailbox;
@class POSDocument;

@interface POSModelManager : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 *  helpers used in predicates when traveling down the hierarchy
 */
@property (nonatomic, strong) NSString *selectedMailboxDigipostAddress;

+ (instancetype)sharedManager;

- (void)updateRootResourceWithAttributes:(NSDictionary *)attributes;
- (void)updateBankAccountWithAttributes:(NSDictionary *)attributes;
- (void)updateDocumentsInFolderWithName:(NSString *)folderName mailboxDigipostAddress:(NSString *)digipostAddress attributes:(NSDictionary *)attributes;
- (NSNumber*) numberOfUnreadDocumentsInfolder:(NSString *)folderName mailboxDigipostAddress:(NSString *)digipostAddress;
- (void)updateDocument:(POSDocument *)document withAttributes:(NSDictionary *)attributes;
- (void)deleteDocument:(POSDocument *)document;
- (void)deleteAllObjects;
- (void)deleteAllGCMTokens;
- (NSEntityDescription *)rootResourceEntity;
- (NSEntityDescription *)mailboxEntity;
- (NSEntityDescription *)folderEntity;
- (NSEntityDescription *)documentEntity;
- (NSEntityDescription *)attachmentEntity;
- (NSEntityDescription *)invoiceEntity;
- (NSDate *)rootResourceCreatedAt;
- (void)logExecuteFetchRequestWithError:(NSError *)error;
- (void)logSavingManagedObjectContextWithError:(NSError *)error;
- (void)logSavingManagedObjectContext;
@end
