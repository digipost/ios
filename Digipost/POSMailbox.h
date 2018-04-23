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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class POSFolder, POSRootResource;

@interface POSMailbox : NSManagedObject

@property (nonatomic, retain) NSString *createFolderUri;
@property (nonatomic, retain) NSString *digipostAddress;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *owner;
@property (nonatomic, retain) NSString *updateFoldersUri;
@property (nonatomic, retain) NSNumber *unreadItemsInInbox;
@property (nonatomic, retain) NSSet *folders;
@property (nonatomic, retain) NSString *sendUri;
@property (nonatomic, retain) POSRootResource *rootResource;
@end

@interface POSMailbox (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(POSFolder *)value;
- (void)removeFoldersObject:(POSFolder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

@end
