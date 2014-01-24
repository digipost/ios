//
//  SHCReceipt.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCReceipt.h"
#import "SHCModelManager.h"
#import "SHCMailbox.h"
#import "NSString+SHA1String.h"
#import "SHCFileManager.h"

// Core Data model entity names
NSString *const kReceiptEntityName = @"Receipt";

// API Keys
NSString *const kReceiptReceiptAPIKey = @"receipt";
NSString *const kReceiptCardAPIKey = @"card";
NSString *const kReceiptFranchiseNameAPIKey = @"franchiceName"; // [sic]
NSString *const kReceiptReceiptIdAPIKey = @"id";
NSString *const kReceiptLinkAPIKey = @"link";
NSString *const kReceiptLinkDeleteUriAPIKeySuffix = @"delete_receipt";
NSString *const kReceiptLinkUriAPIKeySuffix = @"get_receipt_as_html";

@implementation SHCReceipt

// Attributes
@dynamic amount;
@dynamic card;
@dynamic currency;
@dynamic deleteUri;
@dynamic franchiseName;
@dynamic mailboxDigipostAddress;
@dynamic receiptId;
@dynamic storeName;
@dynamic timeOfPurchase;
@dynamic uri;

// Relationships
@dynamic mailbox;

// Overridden properties
@synthesize fileType = _fileType;

#pragma mark - NSObject

- (instancetype)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        _fileType = @"html";
    }

    return self;
}

#pragma mark - Public methods

+ (instancetype)receiptWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[SHCModelManager sharedManager] receiptEntity];
    SHCReceipt *receipt = [[SHCReceipt alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

    NSNumber *amount = attributes[NSStringFromSelector(@selector(amount))];
    receipt.amount = [amount isKindOfClass:[NSNumber class]] ? amount : nil;

    NSArray *cards = attributes[kReceiptCardAPIKey];
    if ([cards isKindOfClass:[NSArray class]]) {
        NSString *card = [cards firstObject];
        if ([card isKindOfClass:[NSString class]]) {
            receipt.card = card;
        }
    }

    NSString *currency = attributes[NSStringFromSelector(@selector(currency))];
    receipt.currency = [currency isKindOfClass:[NSString class]] ? currency : nil;

    NSString *franchiseName = attributes[kReceiptFranchiseNameAPIKey];
    receipt.franchiseName = [franchiseName isKindOfClass:[NSString class]] ? franchiseName : nil;

    NSString *receiptId = attributes[kReceiptReceiptIdAPIKey];
    receipt.receiptId = [receiptId isKindOfClass:[NSString class]] ? receiptId : nil;

    NSString *storeName = attributes[NSStringFromSelector(@selector(storeName))];
    receipt.storeName = [storeName isKindOfClass:[NSString class]] ? storeName : nil;

    NSString *timeOfPurchseString = attributes[NSStringFromSelector(@selector(timeOfPurchase))];
    if ([timeOfPurchseString isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";

        receipt.timeOfPurchase = [dateFormatter dateFromString:timeOfPurchseString];
    }

    NSArray *links = attributes[kReceiptLinkAPIKey];
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {

                    if ([rel hasSuffix:kReceiptLinkDeleteUriAPIKeySuffix]) {
                        receipt.deleteUri = uri;
                    } else if ([rel hasSuffix:kReceiptLinkUriAPIKeySuffix]) {
                        receipt.uri = uri;
                    }
                }
            }
        }
    }

    return receipt;
}

+ (instancetype)existingReceiptWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] receiptEntity];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(uri)), uri];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}

+ (void)reconnectDanglingReceiptsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // At this point, all our Mailbox objects have been created anew.
    // Because the relationship from Mailbox to Receipt is of type Nullify,
    // this means that all Receipts have their mailbox property set to nil.
    // Let's reconnect all Receipts to their respective Mailboxes,
    // and delete those that doesn't match.

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] mailboxEntity];

    NSError *error = nil;
    NSArray *mailboxes = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    fetchRequest.entity = [[SHCModelManager sharedManager] receiptEntity];

    error = nil;
    NSArray *receipts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    NSMutableArray *remainingReceipts = [NSMutableArray arrayWithArray:receipts];

    for (SHCReceipt *receipt in receipts) {
        for (SHCMailbox *mailbox in mailboxes) {
            if ([receipt.mailboxDigipostAddress compare:mailbox.digipostAddress options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [mailbox addReceiptsObject:receipt];

                [remainingReceipts removeObject:receipt];
            }
        }
    }

    // Delete all remaining receipts that we couldn't match
    for (SHCReceipt *receipt in remainingReceipts) {
        [managedObjectContext deleteObject:receipt];
    }
}

+ (NSArray *)allReceiptsWithMailboxWithDigipostAddress:(NSString *)digipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] receiptEntity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(mailboxDigipostAddress)), digipostAddress];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return results;
}

+ (NSString *)stringForReceiptAmount:(NSNumber *)amount
{
    CGFloat decimalAmount = [amount floatValue] / 100.0;

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setLocale:[NSLocale currentLocale]];

    NSString *decimalAmountString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:decimalAmount]];
    NSString *string = [NSString stringWithFormat:@"%@ kr", decimalAmountString];

    return string;
}

@end
