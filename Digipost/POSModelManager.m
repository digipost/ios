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

#import "POSModelManager.h"
#import "POSRootResource.h"
#import "POSMailbox.h"
#import "POSDocument.h"
#import "POSFolder+Methods.h"
#import "POSAttachment.h"
#import "POSInvoice.h"
#import "POSReceipt.h"
#import "POSMailbox+Methods.h"

NSString *const kSQLiteDatabaseName = @"database";
NSString *const kSQLiteDatabaseExtension = @"sqlite";

// API keys
NSString *const kAccountAPIKey = @"account";
NSString *const kAccountAccountNumberAPIKey = @"accountNumber";

@interface POSModelManager ()

@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation POSModelManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Public methods

+ (instancetype)sharedManager
{
    static POSModelManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[POSModelManager alloc] init];
    });

    return sharedInstance;
}

- (void)updateRootResourceWithAttributes:(NSDictionary *)attributes
{
    // First, delete the root resource and its cascaded mailboxes and folders
    [POSRootResource deleteAllRootResourcesInManagedObjectContext:self.managedObjectContext];

    // Then, create a new root resource with related mailboxes and folders
    [POSRootResource rootResourceWithAttributes:attributes
                         inManagedObjectContext:self.managedObjectContext];
    //    // Now we need to reconnect "old" documents so they're available to the user
    //    // before updateDocumentsWithAttribtues: has been called and finished
    [POSDocument reconnectDanglingDocumentsInManagedObjectContext:self.managedObjectContext];
    //
    //    // The same goes for the receipts
    [POSReceipt reconnectDanglingReceiptsInManagedObjectContext:self.managedObjectContext];
    //
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)updateBankAccountWithAttributes:(NSDictionary *)attributes
{
    POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:self.managedObjectContext];

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
    POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:self.managedObjectContext];

    NSNumber *numberOfCards = attributes[NSStringFromSelector(@selector(numberOfCards))];
    rootResource.numberOfCards = [numberOfCards isKindOfClass:[NSNumber class]] ? numberOfCards : @0;

    NSNumber *numberOfCardsReadyForVerification = attributes[NSStringFromSelector(@selector(numberOfCardsReadyForVerification))];
    rootResource.numberOfCardsReadyForVerification = [numberOfCardsReadyForVerification isKindOfClass:[NSNumber class]] ? numberOfCardsReadyForVerification : @0;

    NSNumber *numberOfReceiptsHiddenUntilVerification = attributes[NSStringFromSelector(@selector(numberOfReceiptsHiddenUntilVerification))];
    rootResource.numberOfReceiptsHiddenUntilVerification = [numberOfReceiptsHiddenUntilVerification isKindOfClass:[NSNumber class]] ? numberOfReceiptsHiddenUntilVerification : @0;
}

- (void)updateDocumentsInFolderWithName:(NSString *)folderName mailboxDigipostAddress:(NSString *)digipostAddress attributes:(NSDictionary *)attributes
{
    NSParameterAssert(digipostAddress);
    NSParameterAssert(folderName);

    // First, find the folder object
    POSFolder *folder = [POSFolder existingFolderWithName:folderName
                                   mailboxDigipostAddress:digipostAddress
                                   inManagedObjectContext:self.managedObjectContext];

    // Get a list of all the old documents
    NSArray *oldDocuments = [POSDocument allDocumentsInFolderWithName:folderName
                                               mailboxDigipostAddress:digipostAddress
                                               inManagedObjectContext:self.managedObjectContext];

    // Create all the new documents
    NSDictionary *documents = attributes[kDocumentDocumentsAPIKey];
    NSArray *documentsArray = documents[kDocumentDocumentAPIKey];

    // used for the main mailbox json structure, not custom folders
    if (documentsArray == nil) {
        documentsArray = attributes[kDocumentDocumentAPIKey];
    }
    if ([documentsArray isKindOfClass:[NSArray class]]) {
        [documentsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            POSDocument *document = [POSDocument documentWithAttributes:obj
                                                 inManagedObjectContext:self.managedObjectContext];
            document.folder = folder;
            document.folderUri = folder.uri;
            [folder addDocumentsObject:document];
        }];
    }

    // Delete the old ones
    for (POSDocument *oldDocument in oldDocuments) {
        [self.managedObjectContext deleteObject:oldDocument];
    }

    // And finally, save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)updateDocument:(POSDocument *)document withAttributes:(NSDictionary *)attributes
{
    [document updateWithAttributes:attributes
            inManagedObjectContext:self.managedObjectContext];

    document.folder = [POSFolder pos_existingFolderWithUri:document.folderUri
                                    inManagedObjectContext:self.managedObjectContext];
    // Save changes#
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)deleteDocument:(POSDocument *)document
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
    POSMailbox *mailbox = [POSMailbox existingMailboxWithDigipostAddress:digipostAddress
                                                  inManagedObjectContext:self.managedObjectContext];

    // Get a list of all old receipts
    NSArray *oldReceipts = [POSReceipt allReceiptsWithMailboxWithDigipostAddress:digipostAddress
                                                          inManagedObjectContext:self.managedObjectContext];

    NSArray *receipts = attributes[kReceiptReceiptAPIKey];
    if ([receipts isKindOfClass:[NSArray class]]) {
        for (NSDictionary *receiptDict in receipts) {
            if ([receiptDict isKindOfClass:[NSDictionary class]]) {
                POSReceipt *receipt = [POSReceipt receiptWithAttributes:receiptDict
                                                 inManagedObjectContext:self.managedObjectContext];
                receipt.mailbox = mailbox;
                receipt.mailboxDigipostAddress = mailbox.digipostAddress;
            }
        }
    }

    // Delete the old ones
    for (POSReceipt *oldReceipt in oldReceipts) {
        [self.managedObjectContext deleteObject:oldReceipt];
    }

    // And finally, save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (void)deleteReceipt:(POSReceipt *)receipt
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
    [POSRootResource deleteAllRootResourcesInManagedObjectContext:self.managedObjectContext];
    [POSReceipt deleteAllReceiptsInManagedObjectContext:self.managedObjectContext];
    [POSDocument deleteAllDocumentsInManagedObjectContext:self.managedObjectContext];
    [POSMailbox deleteAllMailboxesInManagedObjectContext:self.managedObjectContext];

    // Save changes
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
}

- (NSEntityDescription *)rootResourceEntity
{
    return [NSEntityDescription entityForName:kRootResourceEntityName
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)mailboxEntity
{
    return [NSEntityDescription entityForName:kMailboxEntityName
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)folderEntity
{
    return [NSEntityDescription entityForName:kFolderEntityName
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)documentEntity
{
    return [NSEntityDescription entityForName:kDocumentEntityName
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)attachmentEntity
{
    return [NSEntityDescription entityForName:kAttachmentEntityName
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)invoiceEntity
{
    return [NSEntityDescription entityForName:kInvoiceEntityName
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)receiptEntity
{
    return [NSEntityDescription entityForName:kReceiptEntityName
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSDate *)rootResourceCreatedAt
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kRootResourceEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                error:&error];
    if (error) {
        [self logExecuteFetchRequestWithError:error];
    }

    POSRootResource *rootResource = [results firstObject];

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

- (void)logSavingManagedObjectContext
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logSavingManagedObjectContextWithError:error];
    }
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

#pragma mark - Private methods

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithRetries:(BOOL)retries
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *storePath = [documentsDirectory stringByAppendingPathComponent:[kSQLiteDatabaseName stringByAppendingFormat:@".%@", kSQLiteDatabaseExtension]];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

    // The options dictionary will enable Lightweight Migration if possible
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                               NSInferMappingModelAutomaticallyOption : @YES };

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeUrl
                                                         options:options
                                                           error:&error]) {

        DDLogError(@"Error adding the persistent store to the coordinator: %@", [error localizedDescription]);

        if (retries) {
            // Delete the SQLite database file and try again
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:storeUrl
                                                           error:&error]) {
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
