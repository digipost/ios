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
NSString *const kMailboxLinkDocumentInboxAPIKeySuffix = @"document_inbox";
NSString *const kMailboxLinkDocumentWorkAreaAPIKeySuffix = @"document_workarea";
NSString *const kMailboxLinkDocumentArchiveAPIKeySuffix = @"document_archive";
NSString *const kMailboxLinkReceiptsAPIKeySuffix = @"receipts";

@implementation SHCMailbox

// Attributes
@dynamic digipostAddress;
@dynamic owner;
@dynamic receiptsUri;

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
                    if ([rel hasSuffix:kMailboxLinkDocumentInboxAPIKeySuffix]) {
                        folderAttributes = @{NSStringFromSelector(@selector(name)): kFolderInboxName,
                                             NSStringFromSelector(@selector(uri)): uri};
                    } else if ([rel hasSuffix:kMailboxLinkDocumentWorkAreaAPIKeySuffix]) {
                        folderAttributes = @{NSStringFromSelector(@selector(name)): kFolderWorkAreaName,
                                             NSStringFromSelector(@selector(uri)): uri};
                    } else if ([rel hasSuffix:kMailboxLinkDocumentArchiveAPIKeySuffix]) {
                        folderAttributes = @{NSStringFromSelector(@selector(name)): kFolderArchiveName,
                                             NSStringFromSelector(@selector(uri)): uri};
                    } else if ([rel hasSuffix:kMailboxLinkReceiptsAPIKeySuffix]) {
                        mailbox.receiptsUri = uri;
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

+ (instancetype)existingMailboxWithDigipostAddress:(NSString *)digipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] mailboxEntity];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(digipostAddress)), digipostAddress];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}

@end
