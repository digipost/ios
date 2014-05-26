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

#import "POSFolder.h"
#import "POSModelManager.h"
#import "NSPredicate+CommonPredicates.h"

// Core Data model entity names
NSString *const kFolderEntityName = @"Folder";

// Hard-coded folder names that we'll use until all folders are made dynamic in the Digipost system
NSString *const kFolderInboxName = @"Inbox";
NSString *const kFolderWorkAreaName = @"WorkArea";
NSString *const kFolderArchiveName = @"Archive";

@implementation POSFolder

// Attributes
@dynamic name;
@dynamic uri;

// Relationships
@dynamic documents;
@dynamic mailbox;

#pragma mark - Public methods

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
    //    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K LIKE[cd] %@", NSStringFromSelector(@selector(name)), folderName];
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
    return nil;
}
@end
