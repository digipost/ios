//
//  SHCInvoice.m
//  Digipost
//
//  Created by Eivind Bohler on 15.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCInvoice.h"
#import "SHCAttachment.h"
#import "SHCModelManager.h"

// Core Data model entity names
NSString *const kInvoiceEntityName = @"Invoice";

// API keys
NSString *const kInvoiceLinkAPIKey = @"link";
NSString *const kInvoiceLinkSendToBankSuffix = @"send_to_bank";
NSString *const kInvoicePaymentAPIKey = @"payment";
NSString *const kInvoicePaymentLinkAPIKey = @"link";
NSString *const kInvoicePaymentBankHomepageSuffix = @"bank_homepage";

@implementation SHCInvoice

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
    NSEntityDescription *entity = [[SHCModelManager sharedManager] invoiceEntity];
    SHCInvoice *invoice = [[SHCInvoice alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

    NSNumber *accountNumber = attributes[NSStringFromSelector(@selector(accountNumber))];
    invoice.accountNumber = [accountNumber isKindOfClass:[NSNumber class]] ? accountNumber : nil;

    NSNumber *amount = attributes[NSStringFromSelector(@selector(amount))];
    invoice.amount = [amount isKindOfClass:[NSNumber class]] ? amount : nil;

    NSNumber *canBePaidByUser = attributes[NSStringFromSelector(@selector(canBePaidByUser))];
    invoice.canBePaidByUser = [canBePaidByUser isKindOfClass:[NSNumber class]] ? canBePaidByUser : nil;

    NSString *dueDateString = attributes[NSStringFromSelector(@selector(dueDate))];
    if ([dueDateString isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatterWithoutTime = [[NSDateFormatter alloc] init];
        dateFormatterWithoutTime.dateFormat = @"yyyy-MM-dd";

        invoice.dueDate = [dateFormatterWithoutTime dateFromString:dueDateString];
    }

    NSNumber *kid = attributes[NSStringFromSelector(@selector(kid))];
    invoice.kid = [kid isKindOfClass:[NSNumber class]] ? kid : nil;

    NSArray *links = attributes[kInvoiceLinkAPIKey];
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {

                    if ([rel hasSuffix:kInvoiceLinkSendToBankSuffix]) {
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

                        if ([rel hasSuffix:kInvoicePaymentBankHomepageSuffix]) {
                            invoice.bankHomepage = uri;
                        }
                    }
                }
            }
        }
    }

    return invoice;
}

@end
