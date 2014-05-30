//
//  POSFolder+Methods.m
//  Digipost
//
//  Created by Håkon Bogen on 21.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSFolder+Methods.h"
#import "NSNumber+JsonParsing.h"
#import "POSModelManager.h"
#import "NSPredicate+CommonPredicates.h"
#import "NSString+CoreDataConvenience.h"

NSString *const kFolderEntityName = @"Folder";

NSString *const kFolderInboxName = @"Inbox";
NSString *const kFolderWorkAreaName = @"WorkArea";
NSString *const kFolderArchiveName = @"Archive";

NSString *const kFolderIconKey = @"icon";
NSString *const kFolderIdKey = @"id";

NSString *const kMailboxLinkChangeFolderAPIKeySuffix = @"change_folder";
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
