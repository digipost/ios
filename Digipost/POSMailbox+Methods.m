//
//  POSMailbox+Methods.m
//  Digipost
//
//  Created by Håkon Bogen on 26.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSMailbox+Methods.h"
#import "POSModelManager.h"

// API keys
NSString *const kMailboxDigipostAddressAPIKey = @"digipostaddress";
NSString *const kMailboxLinkDocumentInboxAPIKeySuffix = @"document_inbox";
NSString *const kMailboxLinkDocumentWorkAreaAPIKeySuffix = @"document_workarea";
NSString *const kMailboxLinkDocumentArchiveAPIKeySuffix = @"document_archive";
NSString *const kMailboxLinkReceiptsAPIKeySuffix = @"receipts";

@implementation POSMailbox (Methods)

#pragma mark - Public methods

+ (instancetype)mailboxWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[POSModelManager sharedManager] mailboxEntity];
    POSMailbox *mailbox = [[POSMailbox alloc] initWithEntity:entity
                              insertIntoManagedObjectContext:managedObjectContext];

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
                        folderAttributes = @{ NSStringFromSelector(@selector(name)) : kFolderInboxName,
                                              NSStringFromSelector(@selector(uri)) : uri };
                    } else if ([rel hasSuffix:kMailboxLinkDocumentWorkAreaAPIKeySuffix]) {
                        folderAttributes = @{ NSStringFromSelector(@selector(name)) : kFolderWorkAreaName,
                                              NSStringFromSelector(@selector(uri)) : uri };
                    } else if ([rel hasSuffix:kMailboxLinkDocumentArchiveAPIKeySuffix]) {
                        folderAttributes = @{ NSStringFromSelector(@selector(name)) : kFolderArchiveName,
                                              NSStringFromSelector(@selector(uri)) : uri };
                    } else if ([rel hasSuffix:kMailboxLinkReceiptsAPIKeySuffix]) {
                        mailbox.receiptsUri = uri;
                    }

                    if (folderAttributes) {
                        POSFolder *folder = [POSFolder folderWithAttributes:folderAttributes
                                                     inManagedObjectContext:managedObjectContext];
                        [mailbox addFoldersObject:folder];
                        folder.mailbox = mailbox;
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
    fetchRequest.entity = [[POSModelManager sharedManager] mailboxEntity];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(digipostAddress)), digipostAddress];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}
+ (POSMailbox *)mailboxInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:kMailboxEntityName
                                      inManagedObjectContext:managedObjectContext];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return results[0];
}

+ (NSInteger)numberOfMailboxesStoredInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:kMailboxEntityName
                                      inManagedObjectContext:managedObjectContext];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }
    return [results count];
}

+ (void)deleteAllMailboxesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:kMailboxEntityName
                                      inManagedObjectContext:managedObjectContext];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    for (POSMailbox *mailbox in results) {
        [managedObjectContext deleteObject:mailbox];
    }
}
@end
