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

#import "POSMailbox+Methods.h"
#import "POSFolder+Methods.h"
#import "POSModelManager.h"

// API keys
NSString *const kMailboxDigipostAddressAPIKey = @"digipostaddress";
NSString *const kMailboxNameAPIKey = @"name";
NSString *const kMailboxLinkDocumentInboxAPIKeySuffix = @"document_inbox";
NSString *const kMailboxLinkDocumentWorkAreaAPIKeySuffix = @"document_workarea";
NSString *const kMailboxLinkDocumentArchiveAPIKeySuffix = @"document_archive";
NSString *const kMailboxLinkReceiptsAPIKeySuffix = @"receipts";
NSString *const kMailboxLinkCreateFolderAPIKeySuffix = @"create_folder";
NSString *const kMailboxLinkUpdateFoldersAPIKeySuffix = @"update_folders";
NSString *const kMailboxLinkUploadToInboxFolderAPIKeySuffix = @"upload_document_to_inbox";
NSString *const kMailboxUnreadItemsInInbox = @"unreadItemsInInbox";
NSString *const kMailboxLinkCreateMessageAPIKeySuffix = @"create_message";

NSString *const kMailboxLinkFoldersAPIKeySuffix = @"folders";
NSString *const kMailboxLinkFolderAPIKeySuffix = @"folder";

// Core Data model entity names
NSString *const kMailboxEntityName = @"Mailbox";

@implementation POSMailbox (Methods)

#pragma mark - Public methods

+ (instancetype)mailboxWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[POSModelManager sharedManager] mailboxEntity];

    POSMailbox *mailbox = [[POSMailbox alloc] initWithEntity:entity
                              insertIntoManagedObjectContext:managedObjectContext];
    NSString *digipostAddress = attributes[kMailboxDigipostAddressAPIKey];
    mailbox.digipostAddress = [digipostAddress isKindOfClass:[NSString class]] ? digipostAddress : nil;
    NSString *name = attributes[kMailboxNameAPIKey];
    mailbox.name = [name isKindOfClass:[NSString class]] ? name : nil;

    NSNumber *owner = attributes[NSStringFromSelector(@selector(owner))];
    mailbox.owner = [owner isKindOfClass:[NSNumber class]] ? owner : nil;

    mailbox.unreadItemsInInbox =
        [attributes[kMailboxUnreadItemsInInbox] isKindOfClass:[NSNumber class]]
            ? attributes[kMailboxUnreadItemsInInbox]
            : @0;

    NSArray *links = attributes[@"link"];
    NSString *uploadDocumentURI = @"";
    POSFolder *inboxFolder;
    __block NSInteger index = 1;
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
                    } else if ([rel hasSuffix:kMailboxLinkDocumentArchiveAPIKeySuffix]) {
                    } else if ([rel hasSuffix:kMailboxLinkReceiptsAPIKeySuffix]) {
                        mailbox.receiptsUri = uri;
                    }
                    if ([rel hasSuffix:kMailboxLinkUploadToInboxFolderAPIKeySuffix]) {
                        uploadDocumentURI = uri;
                    }
                    if ([rel hasSuffix:kMailboxLinkCreateMessageAPIKeySuffix]) {
                        mailbox.sendUri = uri;
                    }
                    if (folderAttributes) {
                        POSFolder *folder = [POSFolder folderWithAttributes:folderAttributes
                                                     inManagedObjectContext:managedObjectContext];
                        [mailbox addFoldersObject:folder];
                        folder.index = @(0);
                        folder.mailbox = mailbox;
                        inboxFolder = folder;
                    }
                }
            }
        }
    }
    inboxFolder.uploadDocumentUri = uploadDocumentURI;

    NSDictionary *folders = attributes[kMailboxLinkFoldersAPIKeySuffix];

    NSArray *foldersForMailbox = folders[kMailboxLinkFolderAPIKeySuffix];
    [foldersForMailbox enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        POSFolder *folder = [POSFolder userMadeFolderWithAttributes:obj
                                     inManagedObjectContext:managedObjectContext];
        folder.index = @(index++);
        [mailbox addFoldersObject:folder];
        folder.mailbox = mailbox;
    }];

    NSArray *link = folders[@"link"];
    [link enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *linkDict = (id) obj;
        NSString *rel = linkDict[@"rel"];
        if ([rel hasSuffix:kMailboxLinkCreateFolderAPIKeySuffix]){
            mailbox.createFolderUri = linkDict[@"uri"];
        }
        else if ([rel hasSuffix:kMailboxLinkUpdateFoldersAPIKeySuffix]){
            mailbox.updateFoldersUri = linkDict[@"uri"];
        }
    }];
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

+ (POSMailbox *)mailboxOwnerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:kMailboxEntityName
                                      inManagedObjectContext:managedObjectContext];

    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(owner)), @YES];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }
    if ([results count] > 0) {
        return results[0];
    }

    return nil;
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
