//
//  SHCMailbox.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCMailbox.h"
#import "SHCFolder.h"
#import "SHCModelManager.h"

// Core Data model entity names
NSString *const kMailboxEntityName = @"Mailbox";

// API keys
NSString *const kMailboxDigipostAddressAPIKey = @"digipostaddress";
NSString *const kMailboxLinkDocumentInboxSuffix = @"document_inbox";
NSString *const kMailboxLinkDocumentWorkAreaSuffix = @"document_workarea";
NSString *const kMailboxLinkDocumentArchiveSuffix = @"document_archive";

@implementation SHCMailbox

// Attributes
@dynamic digipostAddress;
@dynamic owner;

// Relationships
@dynamic folders;
@dynamic rootResource;

#pragma mark - Public methods

+ (instancetype)mailboxWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[SHCModelManager sharedManager] mailboxEntity];
    SHCMailbox *mailbox = [[SHCMailbox alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

    NSString *digipostAddress = attributes[kMailboxDigipostAddressAPIKey];
    mailbox.digipostAddress = [digipostAddress isKindOfClass:[NSString class]] ? digipostAddress : nil;

    NSNumber *owner = attributes[NSStringFromSelector(@selector(owner))];
    mailbox.owner = [owner isKindOfClass:[NSNumber class]] ? owner : nil;

    NSArray *links = attributes[@"link"];
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {

                    NSDictionary *folderAttributes = nil;
                    if ([rel hasSuffix:kMailboxLinkDocumentInboxSuffix]) {
                        folderAttributes = @{NSStringFromSelector(@selector(name)): kFolderInboxName,
                                             NSStringFromSelector(@selector(uri)): uri};
                    } else if ([rel hasSuffix:kMailboxLinkDocumentWorkAreaSuffix]) {
                        folderAttributes = @{NSStringFromSelector(@selector(name)): kFolderWorkAreaName,
                                             NSStringFromSelector(@selector(uri)): uri};
                    } else if ([rel hasSuffix:kMailboxLinkDocumentArchiveSuffix]) {
                        folderAttributes = @{NSStringFromSelector(@selector(name)): kFolderArchiveName,
                                             NSStringFromSelector(@selector(uri)): uri};
                    }

                    if (folderAttributes) {
                        SHCFolder *folder = [SHCFolder folderWithAttributes:folderAttributes inManagedObjectContext:managedObjectContext];
                        [mailbox addFoldersObject:folder];
                    }
                }
            }
        }
    }

    return mailbox;
}

@end
