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

#import "POSFolder+Methods.h"
#import "NSNumber+JsonParsing.h"
#import "POSModelManager.h"
#import "POSAttachment.h"
#import "NSPredicate+CommonPredicates.h"
#import "POSDocument.h"
#import "NSString+CoreDataConvenience.h"
#import "Digipost-Swift.h"

NSString *const kFolderEntityName = @"Folder";

NSString *const kFolderInboxName = @"Inbox";
NSString *const kFolderWorkAreaName = @"WorkArea";
NSString *const kFolderArchiveName = @"Archive";

NSString *const kFolderIconKey = @"icon";
NSString *const kFolderIdKey = @"id";

NSString *const kMailboxLinkChangeFolderAPIKeySuffix = @"change_folder";
NSString *const kMailboxLinkUploadDocumentToFolderAPIKeySuffix = @"upload_document";
NSString *const kMailboxLinkDeleteFolderAPIKeySuffix = @"delete_folder";
NSString *const kMailboxLinkFolderURIAPIKeySuffix = @"self";

@implementation POSFolder (Methods)
+ (instancetype)pos_existingFolderWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] folderEntity];
    fetchRequest.predicate = [NSPredicate predicateForFolderWithUri:uri];

    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}

+ (instancetype)userMadeFolderWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[POSModelManager sharedManager] folderEntity];
    POSFolder *folder = [[POSFolder alloc] initWithEntity:entity
                           insertIntoManagedObjectContext:managedObjectContext];

    NSString *name = attributes[NSStringFromSelector(@selector(name))];
    folder.name = [name isKindOfClass:[NSString class]] ? name : nil;

    NSString *icon = attributes[kFolderIconKey];
    folder.iconName = [NSString nilOrValueForValue:icon];

    NSNumber *folderId = attributes[kFolderIdKey];
    folder.folderId = [NSNumber nilOrValueForValue:folderId];

    NSArray *linkArray = attributes[@"link"];
    [linkArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *apiLinks = (id)obj;
        NSString *rel = apiLinks[@"rel"];
        NSString *uri = apiLinks[@"uri"];
        if ([rel hasSuffix:kMailboxLinkChangeFolderAPIKeySuffix]){
            folder.changeFolderUri = uri;
        }else if ([rel hasSuffix:kMailboxLinkDeleteFolderAPIKeySuffix]){
            folder.deletefolderUri = uri;
        }else if ([rel hasSuffix:kMailboxLinkFolderURIAPIKeySuffix]) {
            folder.uri = uri;
        }else if ([rel hasSuffix:kMailboxLinkUploadDocumentToFolderAPIKeySuffix]){
            folder.uploadDocumentUri = uri;
        }
    }];
    NSAssert(folder.uri != nil, @"no uri set");
    NSAssert(folder.name != nil, @"no name set");
    return folder;
}

+ (instancetype)folderWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[POSModelManager sharedManager] folderEntity];
    POSFolder *folder = [[POSFolder alloc] initWithEntity:entity
                           insertIntoManagedObjectContext:managedObjectContext];

    NSString *name = attributes[NSStringFromSelector(@selector(name))];
    folder.name = [name isKindOfClass:[NSString class]] ? name : nil;

    NSString *uri = attributes[NSStringFromSelector(@selector(uri))];
    folder.uri = [uri isKindOfClass:[NSString class]] ? uri : nil;

    return folder;
}

+ (instancetype)existingFolderWithName:(NSString *)folderName mailboxDigipostAddress:(NSString *)mailboxDigipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] folderEntity];
    fetchRequest.predicate = [NSPredicate folderWithName:folderName
                         mailboxDigipostAddressPredicate:mailboxDigipostAddress];
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}

+ (NSArray *)foldersForUserWithMailboxDigipostAddress:(NSString *)mailboxDigipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] folderEntity];
    fetchRequest.predicate = [NSPredicate predicateForFoldersForDigipostAddress:mailboxDigipostAddress];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"index"
                                                                    ascending:YES] ];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return results;
}

// complexity is O(n^2)

- (NSString *)highestOAuth2ScopeForContainedDocuments
{
    __block NSString *highestOAuthScopeInThisFolder = kOauth2ScopeFull;
    __block NSString *highestStoredScope = [OAuthToken oAuthTokenWithHighestScopeInStorage].scope;

    [self.documents enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        POSDocument *document = (id) obj;
        [document.attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            POSAttachment *attachment = (id) obj;
            NSString *scope = [OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel];
            
            if ([OAuthToken oAuthScope:scope isHigherThanOrEqualToScope:highestOAuthScopeInThisFolder]) {
                if ([OAuthToken oAuthScope:scope isHigherThanOrEqualToScope:highestStoredScope] == NO) {
                    highestOAuthScopeInThisFolder = scope;
                }
            }
        }];
    }];
    return highestOAuthScopeInThisFolder;
}

- (NSString *)displayName
{
    if (self.name) {
        if ([self.name isEqualToString:kFolderInboxName]) {
            return NSLocalizedString(@"FOLDER_NAME_INBOX", @"Inbox");
        } else if ([self.name isEqualToString:kFolderWorkAreaName]) {
            return NSLocalizedString(@"FOLDER_NAME_WORKAREA", @"Workarea");
        } else if ([self.name isEqualToString:kFolderArchiveName]) {
            return NSLocalizedString(@"FOLDER_NAME_ARCHIVE", @"Archive");
        }
    }
    return self.name;
}

@end
