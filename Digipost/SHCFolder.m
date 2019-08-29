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

#import "SHCFolder.h"
#import "SHCModelManager.h"

// Core Data model entity names
NSString *const kFolderEntityName = @"Folder";

// Hard-coded folder names that we'll use until all folders are made dynamic in the Digipost system
NSString *const kFolderInboxName = @"Inbox";

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
        }
    }
    return nil;
}
@end
