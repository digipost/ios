//
//  POSMailbox.h
//  Digipost
//
//  Created by Håkon Bogen on 23.06.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class POSFolder, POSReceipt, POSRootResource;

@interface POSMailbox : NSManagedObject

@property (nonatomic, retain) NSString * createFolderUri;
@property (nonatomic, retain) NSString * digipostAddress;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * receiptsUri;
@property (nonatomic, retain) NSString * updateFoldersUri;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *folders;
@property (nonatomic, retain) NSSet *receipts;
@property (nonatomic, retain) POSRootResource *rootResource;
@end

@interface POSMailbox (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(POSFolder *)value;
- (void)removeFoldersObject:(POSFolder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

- (void)addReceiptsObject:(POSReceipt *)value;
- (void)removeReceiptsObject:(POSReceipt *)value;
- (void)addReceipts:(NSSet *)values;
- (void)removeReceipts:(NSSet *)values;

@end
