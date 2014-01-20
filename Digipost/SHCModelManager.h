//
//  SHCModelManager.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
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
- (void)updateDocumentsInFolderWithName:(NSString *)folderName attributes:(NSDictionary *)attributes;
- (void)updateDocument:(SHCDocument *)document withAttributes:(NSDictionary *)attributes;
- (void)deleteDocument:(SHCDocument *)document;
- (void)updateReceiptsInMailboxWithDigipostAddress:(NSString *)digipostAddress attributes:(NSDictionary *)attributes;
- (void)deleteReceipt:(SHCReceipt *)receipt;
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
