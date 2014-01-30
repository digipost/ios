//
//  SHCFolder.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCFolder.h"
#import "SHCModelManager.h"

// Core Data model entity names
NSString *const kFolderEntityName = @"Folder";

// Hard-coded folder names that we'll use until all folders are made dynamic in the Digipost system
NSString *const kFolderInboxName = @"Inbox";
NSString *const kFolderWorkAreaName = @"WorkArea";
NSString *const kFolderArchiveName = @"Archive";

@implementation SHCFolder

// Attributes
@dynamic name;
@dynamic uri;

// Relationships
@dynamic documents;
@dynamic mailbox;

#pragma mark - Public methods

+ (instancetype)folderWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[SHCModelManager sharedManager] folderEntity];
    SHCFolder *folder = [[SHCFolder alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

    NSString *name = attributes[NSStringFromSelector(@selector(name))];
    folder.name = [name isKindOfClass:[NSString class]] ? name : nil;

    NSString *uri = attributes[NSStringFromSelector(@selector(uri))];
    folder.uri = [uri isKindOfClass:[NSString class]] ? uri : nil;

    return folder;
}

+ (instancetype)existingFolderWithName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] folderEntity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K LIKE[cd] %@", NSStringFromSelector(@selector(name)), folderName];
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}

- (NSString *)displayName
{
    if (self.name){
        if ([self.name isEqualToString:kFolderInboxName]){
            return NSLocalizedString(@"FOLDER_NAME_INBOX", @"Inbox");
        }else if ([self.name isEqualToString:kFolderWorkAreaName]){
            return NSLocalizedString(@"FOLDER_NAME_WORKAREA", @"Workarea");
        }else if ([self.name isEqualToString:kFolderArchiveName]){
            return  NSLocalizedString(@"FOLDER_NAME_ARCHIVE", @"Archive");
        }
    }
    return nil;
}
@end
