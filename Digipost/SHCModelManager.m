//
//  SHCModelManager.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SHCModelManager.h"
#import "SHCRootResource.h"

NSString *const kSQLiteDatabaseName = @"database";
NSString *const kSQLiteDatabaseExtension = @"sqlite";

@interface SHCModelManager ()

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
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
    [SHCRootResource rootResourceWithAttributes:attributes inManagedObjectContext:self.managedObjectContext];

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        DDLogError(@"Error saving managed object context: %@, %@", error, [error userInfo]);
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
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString *storePath = [documentsDirectory stringByAppendingPathComponent:[kSQLiteDatabaseName stringByAppendingFormat:@".%@", kSQLiteDatabaseExtension]];
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];

	NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

    // The options dictionary will enable Lightweight Migration if possible
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {

		DDLogError(@"Error adding the persistent store to the coordinator: %@, %@", error, [error userInfo]);

        if (retries) {
            // Delete the SQLite database file and try again
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error]) {
                DDLogError(@"Error removing item: %@, %@", error, [error userInfo]);
            }

            _persistentStoreCoordinator = [self persistentStoreCoordinatorWithRetries:NO];

        } else {
            return nil;
        }
    }

    return _persistentStoreCoordinator;
}

@end
