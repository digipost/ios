//
//  POSAttachment.m
//  Digipost
//
//  Created by Håkon Bogen on 30.06.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSAttachment.h"
#import "POSDocument.h"
#import "POSModelManager.h"
#import "POSInvoice.h"

// Defines what the app considers a valid attachment authentication level
NSString *const kAttachmentOpeningValidAuthenticationLevel = @"PASSWORD";

// Custom NSError consts
NSString *const kAttachmentOpeningValidationErrorDomain = @"AttachmentOpeningValidationErrorDomain";

// Core Data model entity names
NSString *const kAttachmentEntityName = @"Attachment";

// Defines Digipost attachment types
NSString *const kAttachmentTypeLetter = @"LETTER";
NSString *const kAttachmentTypeInvoice = @"INVOICE";

// API keys
NSString *const kAttachmentAuthenticationLevel = @"authentication-level";
NSString *const kAttachmentLinkAPIKey = @"link";
NSString *const kAttachmentDocumentContentAPIKeySuffix = @"get_document_content";
NSString *const kAttachmentSendOpeningReceiptAPIKeySuffix = @"send_opening_receipt";
NSString *const kAttachmentInvoiceAPIKey = @"invoice";

NSString *const kAuthenticationLevelIDPorten4 = @"IDPORTEN_4";
NSString *const kAuthenticationLevelIDPorten3 = @"IDPORTEN_3";
NSString *const kAuthenticationLevelTwoFactor = @"TWO_FACTOR";
NSString *const kAuthenticationLevelPassword = @"PASSWORD";

@implementation POSAttachment

@dynamic authenticationLevel;
@dynamic fileSize;
@dynamic fileType;
@dynamic mainDocument;
@dynamic read;
@dynamic subject;
@dynamic type;
@dynamic uri;
@dynamic openingReceiptUri;
@dynamic document;
@dynamic invoice;
@dynamic origin;

#pragma mark - Public methods

+ (instancetype)attachmentWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[POSModelManager sharedManager] attachmentEntity];
    POSAttachment *attachment = [[POSAttachment alloc] initWithEntity:entity
                                       insertIntoManagedObjectContext:managedObjectContext];

    NSString *authenticationLevel = attributes[kAttachmentAuthenticationLevel];
    attachment.authenticationLevel = [authenticationLevel isKindOfClass:[NSString class]] ? authenticationLevel : nil;

    NSNumber *fileSize = attributes[NSStringFromSelector(@selector(fileSize))];
    attachment.fileSize = [fileSize isKindOfClass:[NSNumber class]] ? fileSize : nil;

    NSString *fileType = attributes[NSStringFromSelector(@selector(fileType))];
    attachment.fileType = [fileType isKindOfClass:[NSString class]] ? fileType : nil;

    NSNumber *mainDocument = attributes[NSStringFromSelector(@selector(mainDocument))];
    attachment.mainDocument = [mainDocument isKindOfClass:[NSNumber class]] ? mainDocument : nil;

    NSNumber *read = attributes[NSStringFromSelector(@selector(read))];
    attachment.read = [read isKindOfClass:[NSNumber class]] ? read : nil;

    NSString *subject = attributes[NSStringFromSelector(@selector(subject))];
    attachment.subject = [subject isKindOfClass:[NSString class]] ? subject : nil;

    NSString *type = attributes[NSStringFromSelector(@selector(type))];
    attachment.type = [type isKindOfClass:[NSString class]] ? type : nil;

    NSString *origin = attributes[NSStringFromSelector(@selector(origin))];
    attachment.origin = [type isKindOfClass:[NSString class]] ? origin : nil;

    NSArray *links = attributes[kAttachmentLinkAPIKey];
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {
                    if ([rel hasSuffix:kAttachmentDocumentContentAPIKeySuffix]) {
                        attachment.uri = uri;
                    }
                    if ([rel hasSuffix:kAttachmentSendOpeningReceiptAPIKeySuffix]) {
                        attachment.openingReceiptUri = uri;
                    }
                }
            }
        }
    }

    NSDictionary *invoiceDict = attributes[kAttachmentInvoiceAPIKey];
    if ([invoiceDict isKindOfClass:[NSDictionary class]]) {
        attachment.invoice = [POSInvoice invoiceWithAttributes:invoiceDict
                                        inManagedObjectContext:managedObjectContext];
    }

    return attachment;
}

+ (instancetype)existingAttachmentWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] attachmentEntity];
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

+ (NSString *)uriFromLinksArray:(NSArray *)links withSuffix:(NSString *)suffix
{
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {
                    if ([rel hasSuffix:suffix]) {
                        return uri;
                    }
                }
            }
        }
    }
    return nil;
}

+ (instancetype)updateExistingAttachmentWithUriFromDictionary:(NSDictionary *)attributesDictionary existingAttachment:(POSAttachment *)existingAttachment inManagedObjectContext:(NSManagedObjectContext *)managedObjectcontext
{
    NSArray *links = attributesDictionary[kAttachmentLinkAPIKey];
    NSString *uri = [POSAttachment uriFromLinksArray:links withSuffix:kAttachmentDocumentContentAPIKeySuffix];

    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //    fetchRequest.entity = [[POSModelManager sharedManager] attachmentEntity];
    //    fetchRequest.fetchLimit = 1;
    //    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(uri)), uri];

    //    NSError *error = nil;
    //    NSArray *results = [managedObjectcontext executeFetchRequest:fetchRequest
    //                                                           error:&error];
    //    if (error) {
    //        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    //    }
    //    POSAttachment *attachment = [results firstObject];
    NSString *openingReceiptUri = [POSAttachment uriFromLinksArray:links withSuffix:kAttachmentSendOpeningReceiptAPIKeySuffix];
    existingAttachment.openingReceiptUri = openingReceiptUri;
    existingAttachment.uri = uri;

    return existingAttachment;
}
@end
