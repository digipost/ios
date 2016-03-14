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

@class POSDocument, POSMailbox;

@interface POSFolder : NSManagedObject

@property (nonatomic, retain) NSString * changeFolderUri;
@property (nonatomic, retain) NSString * uploadDocumentUri;
@property (nonatomic, retain) NSString * deletefolderUri;
@property (nonatomic, retain) NSNumber * folderId;
@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSSet *documents;
@property (nonatomic, retain) POSMailbox *mailbox;
@end

@interface POSFolder (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(POSDocument *)value;
- (void)removeDocumentsObject:(POSDocument *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;

@end
