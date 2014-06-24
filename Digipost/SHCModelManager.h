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

@class SHCDocument;
@class SHCReceipt;

@interface SHCModelManager : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedManager;

- (void)updateRootResourceWithAttributes:(NSDictionary *)attributes;
- (void)updateBankAccountWithAttributes:(NSDictionary *)attributes;
- (void)updateCardAttributes:(NSDictionary *)attributes;
- (void)updateDocumentsInFolderWithName:(NSString *)folderName attributes:(NSDictionary *)attributes;
- (void)updateDocument:(SHCDocument *)document withAttributes:(NSDictionary *)attributes;
- (void)deleteDocument:(SHCDocument *)document;
- (void)updateReceiptsInMailboxWithDigipostAddress:(NSString *)digipostAddress attributes:(NSDictionary *)attributes;
- (void)deleteReceipt:(SHCReceipt *)receipt;
- (void)deleteAllObjects;
- (NSEntityDescription *)rootResourceEntity;
- (NSEntityDescription *)mailboxEntity;
- (NSEntityDescription *)folderEntity;
- (NSEntityDescription *)documentEntity;
- (NSEntityDescription *)attachmentEntity;
- (NSEntityDescription *)invoiceEntity;
- (NSEntityDescription *)receiptEntity;
- (NSDate *)rootResourceCreatedAt;
- (void)logExecuteFetchRequestWithError:(NSError *)error;
- (void)logSavingManagedObjectContextWithError:(NSError *)error;

@end
