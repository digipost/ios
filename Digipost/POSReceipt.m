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

#import "POSReceipt.h"
#import "POSModelManager.h"
#import "POSMailbox.h"
#import "NSString+SHA1String.h"
#import "POSFileManager.h"
#import "Digipost-Swift.h"

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

@implementation POSReceipt

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
    self = [super initWithEntity:entity
        insertIntoManagedObjectContext:context];
    if (self) {
        _fileType = @"html";
    }

    return self;
}

#pragma mark - Public methods

+ (instancetype)receiptWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[POSModelManager sharedManager] receiptEntity];
    POSReceipt *receipt = [[POSReceipt alloc] initWithEntity:entity
                              insertIntoManagedObjectContext:managedObjectContext];

    // Because amount is given as a decimal number from the API, and we don't want to risk floating points
    // inaccuracies, we convert to 100th's and store as an integer in Core Data.
    NSNumber *amount = attributes[NSStringFromSelector(@selector(amount))];
    if ([amount isKindOfClass:[NSNumber class]]) {
        receipt.amount = [NSNumber numberWithInteger:round([amount doubleValue] * 100.0)];
    }

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
    fetchRequest.entity = [[POSModelManager sharedManager] receiptEntity];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(uri)), uri];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
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
    fetchRequest.entity = [[POSModelManager sharedManager] mailboxEntity];

    NSError *error = nil;
    NSArray *mailboxes = [managedObjectContext executeFetchRequest:fetchRequest
                                                             error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    fetchRequest.entity = [[POSModelManager sharedManager] receiptEntity];

    error = nil;
    NSArray *receipts = [managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    NSMutableArray *remainingReceipts = [NSMutableArray arrayWithArray:receipts];

    for (POSReceipt *receipt in receipts) {
        for (POSMailbox *mailbox in mailboxes) {
            if ([receipt.mailboxDigipostAddress compare:mailbox.digipostAddress
                                                options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [mailbox addReceiptsObject:receipt];

                [remainingReceipts removeObject:receipt];
            }
        }
    }

    // Delete all remaining receipts that we couldn't match
    for (POSReceipt *receipt in remainingReceipts) {
        [managedObjectContext deleteObject:receipt];
    }
}

+ (void)deleteAllReceiptsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] receiptEntity];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    for (POSReceipt *receipt in results) {
        [managedObjectContext deleteObject:receipt];
    }
}

+ (NSArray *)allReceiptsWithMailboxWithDigipostAddress:(NSString *)digipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] receiptEntity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(mailboxDigipostAddress)), digipostAddress];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return results;
}

- (NSString *)authenticationLevel
{
    return kOauth2ScopeFull;
}

+ (NSString *)stringForReceiptAmount:(NSNumber *)amount
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setLocale:[NSLocale currentLocale]];

    NSNumber *decimalNumber = [NSNumber numberWithDouble:[amount doubleValue] / 100.0];

    NSString *amountString = [numberFormatter stringFromNumber:decimalNumber];
    NSString *string = [NSString stringWithFormat:@"%@ kr", amountString];

    return string;
}

@end
