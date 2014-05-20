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

#import "SHCModelManager.h"
#import "SHCRootResource.h"
#import "SHCMailbox.h"
#import "SHCDocument.h"
#import "SHCAttachment.h"
#import "SHCInvoice.h"
#import "SHCReceipt.h"

NSString *const kSQLiteDatabaseName = @"database";
NSString *const kSQLiteDatabaseExtension = @"sqlite";

// API keys
NSString *const kAccountAPIKey = @"account";
NSString *const kAccountAccountNumberAPIKey = @"accountNumber";

@interface SHCModelManager ()

@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation SHCModelManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Public methods

+ (instancetype)sharedManager
{
    static SHCModelManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SHCModelManager alloc] init];
    });

    return sharedInstance;
}

- (void)updateRootResourceWithAttributes:(NSDictionary *)attributes
{
    // First, delete the root resource and its cascaded mailboxes and folders
    [SHCRootResource deleteAllRootResourcesInManagedObjectContext:self.managedObjectContext];

    // Then, create a new root resource with related mailboxes and folders
    [SHCRootResource rootResourceWithAttributes:attributes inManagedObjectContext:self.managedObjectContext];

    // Now we need to reconnect "old" documents so they're available to the user
    // before updateDocumentsWithAttribtues: has been called and finished
    [SHCDocument reconnectDanglingDocumentsInManagedObjectContext:self.managedObjectContext];

    // The same goes for the receipts
    [SHCReceipt reconnectDanglingReceiptsInManagedObjectContext:self.managedObjectContext];

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)updateBankAccountWithAttributes:(NSDictionary *)attributes
{
    SHCRootResource *rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:self.managedObjectContext];

    NSDictionary *accountDict = attributes[kAccountAPIKey];
    if ([accountDict isKindOfClass:[NSDictionary class]]) {
        NSString *accountNumber = accountDict[kAccountAccountNumberAPIKey];
        if ([accountNumber isKindOfClass:[NSString class]]) {
            rootResource.currentBankAccount = accountNumber;
        }
    }
}

- (void)updateCardAttributes:(NSDictionary *)attributes
{
    SHCRootResource *rootResource = [SHCRootResource existingRootResourceInManagedObjectContext:self.managedObjectContext];

    NSNumber *numberOfCards = attributes[NSStringFromSelector(@selector(numberOfCards))];
    rootResource.numberOfCards = [numberOfCards isKindOfClass:[NSNumber class]] ? numberOfCards : @0;

    NSNumber *numberOfCardsReadyForVerification = attributes[NSStringFromSelector(@selector(numberOfCardsReadyForVerification))];
    rootResource.numberOfCardsReadyForVerification = [numberOfCardsReadyForVerification isKindOfClass:[NSNumber class]] ? numberOfCardsReadyForVerification : @0;

    NSNumber *numberOfReceiptsHiddenUntilVerification = attributes[NSStringFromSelector(@selector(numberOfReceiptsHiddenUntilVerification))];
    rootResource.numberOfReceiptsHiddenUntilVerification = [numberOfReceiptsHiddenUntilVerification isKindOfClass:[NSNumber class]] ? numberOfReceiptsHiddenUntilVerification : @0;
}

- (void)updateDocumentsInFolderWithName:(NSString *)folderName attributes:(NSDictionary *)attributes
{
    // First, find the folder object
    SHCFolder *folder = [SHCFolder existingFolderWithName:folderName inManagedObjectContext:self.managedObjectContext];

    // Get a list of all the old documents
    NSArray *oldDocuments = [SHCDocument allDocumentsInFolderWithName:folderName inManagedObjectContext:self.managedObjectContext];

    // Create all the new documents
    NSArray *documents = attributes[kDocumentDocumentAPIKey];
    if ([documents isKindOfClass:[NSArray class]]) {
        for (NSDictionary *documentDict in documents) {
            if ([documentDict isKindOfClass:[NSDictionary class]]) {
                SHCDocument *document = [SHCDocument documentWithAttributes:documentDict inManagedObjectContext:self.managedObjectContext];
                document.folder = folder;
                [folder addDocumentsObject:document];
            }
        }
    }

    // Delete the old ones
    for (SHCDocument *oldDocument in oldDocuments) {
        [self.managedObjectContext deleteObject:oldDocument];
    }

    // And finally, save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)updateDocument:(SHCDocument *)document withAttributes:(NSDictionary *)attributes
{
    [document updateWithAttributes:attributes inManagedObjectContext:self.managedObjectContext];

    document.folder = [SHCFolder existingFolderWithName:attributes[NSStringFromSelector(@selector(location))] inManagedObjectContext:self.managedObjectContext];

    // Save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)deleteDocument:(SHCDocument *)document
{
    [self.managedObjectContext deleteObject:document];

    // Save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)updateReceiptsInMailboxWithDigipostAddress:(NSString *)digipostAddress attributes:(NSDictionary *)attributes
{
    // First, get the mailbox object
    SHCMailbox *mailbox = [SHCMailbox existingMailboxWithDigipostAddress:digipostAddress inManagedObjectContext:self.managedObjectContext];

    // Get a list of all old receipts
    NSArray *oldReceipts = [SHCReceipt allReceiptsWithMailboxWithDigipostAddress:digipostAddress inManagedObjectContext:self.managedObjectContext];

    NSArray *receipts = attributes[kReceiptReceiptAPIKey];
    if ([receipts isKindOfClass:[NSArray class]]) {
        for (NSDictionary *receiptDict in receipts) {
            if ([receiptDict isKindOfClass:[NSDictionary class]]) {
                SHCReceipt *receipt = [SHCReceipt receiptWithAttributes:receiptDict inManagedObjectContext:self.managedObjectContext];
                receipt.mailbox = mailbox;
                receipt.mailboxDigipostAddress = mailbox.digipostAddress;
            }
        }
    }

    // Delete the old ones
    for (SHCReceipt *oldReceipt in oldReceipts) {
        [self.managedObjectContext deleteObject:oldReceipt];
    }

    // And finally, save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)deleteReceipt:(SHCReceipt *)receipt
{
    [self.managedObjectContext deleteObject:receipt];

    // Save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)deleteAllObjects
{
    [SHCRootResource deleteAllRootResourcesInManagedObjectContext:self.managedObjectContext];
    [SHCReceipt deleteAllReceiptsInManagedObjectContext:self.managedObjectContext];
    [SHCDocument deleteAllDocumentsInManagedObjectContext:self.managedObjectContext];

    // Save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (NSEntityDescription *)rootResourceEntity
{
    return [NSEntityDescription entityForName:kRootResourceEntityName inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)mailboxEntity
{
    return [NSEntityDescription entityForName:kMailboxEntityName inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)folderEntity
{
    return [NSEntityDescription entityForName:kFolderEntityName inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)documentEntity
{
    return [NSEntityDescription entityForName:kDocumentEntityName inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)attachmentEntity
{
    return [NSEntityDescription entityForName:kAttachmentEntityName inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)invoiceEntity
{
    return [NSEntityDescription entityForName:kInvoiceEntityName inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)receiptEntity
{
    return [NSEntityDescription entityForName:kReceiptEntityName inManagedObjectContext:self.managedObjectContext];
}

- (NSDate *)rootResourceCreatedAt
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kRootResourceEntityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self logExecuteFetchRequestWithError:error];
    }

    SHCRootResource *rootResource = [results firstObject];

    return rootResource.createdAt;
}

- (void)logExecuteFetchRequestWithError:(NSError *)error
{
    DDLogError(@"Error executing fetch request: %@", [error localizedDescription]);
}

- (void)logSavingManagedObjectContextWithError:(NSError *)error
{
    DDLogError(@"Error saving managed object context: %@", [error localizedDescription]);
}

#pragma mark - Properties

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        _managedObjectContext.undoManager = nil;
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }

    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [self persistentStoreCoordinatorWithRetries:YES];
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Predicates
- (NSPredicate *)predicateWithFoldersForSelectedMailBox
{
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"mailbox.digipostAddress == %@", self.selectedMailboxDigipostAddress];
    return p1;
}

- (NSPredicate *)predicateWithDocumentsForSelectedMailBoxInFolderWithName:(NSString *)folderName
{
    NSParameterAssert(folderName);
    NSAssert(self.selectedMailboxDigipostAddress != nil, @"no adress set");
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"folder.mailbox.digipostAddress == %@", self.selectedMailboxDigipostAddress];

    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"%K == %@", [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(folder)), NSStringFromSelector(@selector(name))],folderName];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[p1, p2]];
    return predicate;
}

#pragma mark - Private methods

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithRetries:(BOOL)retries
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSString *storePath = [documentsDirectory stringByAppendingPathComponent:[kSQLiteDatabaseName stringByAppendingFormat:@".%@", kSQLiteDatabaseExtension]];
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];

	NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

    // The options dictionary will enable Lightweight Migration if possible
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {

		DDLogError(@"Error adding the persistent store to the coordinator: %@", [error localizedDescription]);

        if (retries) {
            // Delete the SQLite database file and try again
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error]) {
                DDLogError(@"Error removing item: %@", [error localizedDescription]);
            }

            _persistentStoreCoordinator = [self persistentStoreCoordinatorWithRetries:NO];

        } else {
            return nil;
        }
    }

    return _persistentStoreCoordinator;
}

@end
