//
//  SHCAttachment.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCAttachment.h"
#import "SHCModelManager.h"

// Core Data model entity names
NSString *const kAttachmentEntityName = @"Attachment";

// API keys
NSString *const kAttachmentAuthenticationLevel = @"authentication-level";
NSString *const kAttachmentLinkAPIKey = @"link";
NSString *const kAttachmentDocumentContentAPIKey = @"get_document_content";

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

    return attachment;
}

@end
