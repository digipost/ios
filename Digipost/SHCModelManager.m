//
//  SHCModelManager.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCModelManager.h"
#import "SHCRootResource.h"
#import "SHCFolder.h"

NSString *const kSQLiteDatabaseName = @"database";
NSString *const kSQLiteDatabaseExtension = @"sqlite";

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

- (void)updateModelsWithAttributes:(NSDictionary *)attributes
{
    [SHCRootResource deleteAllRootResourcesInManagedObjectContext:self.managedObjectContext];

    [SHCRootResource rootResourceWithAttributes:attributes inManagedObjectContext:self.managedObjectContext];

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        DDLogError(@"Error saving managed object context: %@", [error localizedDescription]);
    }
}

- (NSEntityDescription *)folderEntity
{
    return [NSEntityDescription entityForName:kFolderEntityName inManagedObjectContext:self.managedObjectContext];
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
        DDLogError(@"Error executing fetch request: %@", [error localizedDescription]);
    }

    SHCRootResource *rootResource = [results firstObject];

    return rootResource.createdAt;
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
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
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
