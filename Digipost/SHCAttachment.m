//
//  SHCAttachment.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCAttachment.h"
#import "SHCModelManager.h"
#import "SHCFileManager.h"
#import "NSString+SHA1String.h"
#import "SHCInvoice.h"

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
NSString *const kAttachmentDocumentContentAPIKey = @"get_document_content";
NSString *const kAttachmentInvoiceAPIKey = @"invoice";

@implementation SHCAttachment

// Attributes
@dynamic authenticationLevel;
@dynamic fileSize;
@dynamic fileType;
@dynamic mainDocument;
@dynamic read;
@dynamic subject;
@dynamic type;
@dynamic uri;

// Relationships
@dynamic document;
@dynamic invoice;

#pragma mark - Public methods

+ (instancetype)attachmentWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[SHCModelManager sharedManager] attachmentEntity];
    SHCAttachment *attachment = [[SHCAttachment alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

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

    NSArray *links = attributes[kAttachmentLinkAPIKey];
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {

                    if ([rel hasSuffix:kAttachmentDocumentContentAPIKey]) {
                        attachment.uri = uri;
                    }
                }
            }
        }
    }

    NSDictionary *invoiceDict = attributes[kAttachmentInvoiceAPIKey];
    if ([invoiceDict isKindOfClass:[NSDictionary class]]) {
        attachment.invoice = [SHCInvoice invoiceWithAttributes:invoiceDict inManagedObjectContext:managedObjectContext];
    }

    return attachment;
}

+ (instancetype)existingAttachmentWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] attachmentEntity];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(uri)), uri];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}

- (NSString *)encryptedFilePath
{
    NSString *fileName = [[self.uri SHA1String] stringByAppendingString:[NSString stringWithFormat:@".%@", self.fileType]];

    if (!fileName) {
        return nil;
    }

    NSString *filePath = [[[SHCFileManager sharedFileManager] encryptedFilesFolderPath] stringByAppendingPathComponent:fileName];

    return filePath;
}

- (NSString *)decryptedFilePath
{
    NSString *fileName = [[self.uri SHA1String] stringByAppendingString:[NSString stringWithFormat:@".%@", self.fileType]];

    if (!fileName) {
        return nil;
    }

    NSString *filePath = [[[SHCFileManager sharedFileManager] decryptedFilesFolderPath] stringByAppendingPathComponent:fileName];

    return filePath;
}

@end
