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

#import "POSInvoice.h"
#import "POSAttachment.h"
#import "NSString+Convenience.h"
#import "POSModelManager.h"

// Core Data model entity names
NSString *const kInvoiceEntityName = @"Invoice";

// API keys
NSString *const kInvoiceLinkAPIKey = @"link";
NSString *const kInvoiceLinkSendToBankAPIKeySuffix = @"send_to_bank";
NSString *const kInvoicePaymentAPIKey = @"payment";
NSString *const kInvoicePaymentLinkAPIKey = @"link";
NSString *const kInvoicePaymentBankHomepageAPIKeySuffix = @"bank_homepage";

@implementation POSInvoice

// Attributes
@dynamic accountNumber;
@dynamic amount;
@dynamic canBePaidByUser;
@dynamic dueDate;
@dynamic kid;
@dynamic sendToBankUri;
@dynamic timePaid;
@dynamic bankHomepage;

// Relationships
@dynamic attachment;

#pragma mark - Public methods

+ (instancetype)invoiceWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[POSModelManager sharedManager] invoiceEntity];
    POSInvoice *invoice = [[POSInvoice alloc] initWithEntity:entity
                              insertIntoManagedObjectContext:managedObjectContext];

    NSString *accountNumber = attributes[NSStringFromSelector(@selector(accountNumber))];
    accountNumber = [accountNumber isKindOfClass:[NSString class]] ? accountNumber : nil;
    if (accountNumber) {
        accountNumber = [NSString stringByAddingSpace:accountNumber atIndex:4];
        accountNumber = [NSString stringByAddingSpace:accountNumber atIndex:7];
    }
    invoice.accountNumber = accountNumber;

    // Because amount is given as a decimal number from the API, and we don't want to risk floating points
    // inaccuracies, we convert to 100th's and store as an integer in Core Data.
    NSNumber *amount = attributes[NSStringFromSelector(@selector(amount))];
    if ([amount isKindOfClass:[NSNumber class]]) {
        invoice.amount = [NSNumber numberWithInteger:round([amount doubleValue] * 100.0)];
    }

    NSNumber *canBePaidByUser = attributes[NSStringFromSelector(@selector(canBePaidByUser))];
    invoice.canBePaidByUser = [canBePaidByUser isKindOfClass:[NSNumber class]] ? canBePaidByUser : nil;

    NSString *dueDateString = attributes[NSStringFromSelector(@selector(dueDate))];
    if ([dueDateString isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatterWithoutTime = [[NSDateFormatter alloc] init];
        dateFormatterWithoutTime.dateFormat = @"yyyy-MM-dd";

        invoice.dueDate = [dateFormatterWithoutTime dateFromString:dueDateString];
    }

    NSString *kid = attributes[NSStringFromSelector(@selector(kid))];
    invoice.kid = [kid isKindOfClass:[NSString class]] ? kid : nil;

    NSArray *links = attributes[kInvoiceLinkAPIKey];
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {

                    if ([rel hasSuffix:kInvoiceLinkSendToBankAPIKeySuffix]) {
                        invoice.sendToBankUri = uri;
                    }
                }
            }
        }
    }

    NSDictionary *paymentDict = attributes[kInvoicePaymentAPIKey];
    if ([paymentDict isKindOfClass:[NSDictionary class]]) {
        NSString *timePaidString = paymentDict[NSStringFromSelector(@selector(timePaid))];
        if ([timePaidString isKindOfClass:[NSString class]]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ";
            invoice.timePaid = [dateFormatter dateFromString:timePaidString];
        }

        NSArray *links = paymentDict[kInvoicePaymentLinkAPIKey];
        if ([links isKindOfClass:[NSArray class]]) {
            for (NSDictionary *link in links) {
                if ([link isKindOfClass:[NSDictionary class]]) {
                    NSString *rel = link[@"rel"];
                    NSString *uri = link[@"uri"];
                    if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {
                        if ([rel hasSuffix:kInvoicePaymentBankHomepageAPIKeySuffix]) {
                            invoice.bankHomepage = uri;
                        }
                    }
                }
            }
        }
    }

    return invoice;
}

- (NSString *)statusDescriptionText
{
    if (self.sendToBankUri) {
        return nil;
    } else {
        return NSLocalizedString(@"LETTER_VIEW_CONTROLLER_INVOICE_POPUP_STATUS_DESCRIPTION", @"Sendt til nettbanken");
    }
    return nil;
}

+ (NSString *)stringForInvoiceAmount:(NSNumber *)amount
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setLocale:[NSLocale currentLocale]];

    NSNumber *decimalNumber = [NSNumber numberWithDouble:[amount doubleValue] / 10000.0];

    NSString *amountString = [numberFormatter stringFromNumber:decimalNumber];
    NSString *string = [NSString stringWithFormat:@"%@ kr", amountString];

    return string;
}

@end
