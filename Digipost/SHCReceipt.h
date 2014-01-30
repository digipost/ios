//
//  SHCReceipt.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
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
