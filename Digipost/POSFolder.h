//
//  POSFolder.h
//  Digipost
//
//  Created by Håkon Bogen on 11.06.14.
//  Copyright (c) 2014 Posten. All rights reserved.
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
