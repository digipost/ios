//
//  SHCRootResource.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCRootResource.h"
#import "SHCMailbox.h"
#import "SHCModelManager.h"

// Core Data model entity names
NSString *const kRootResourceEntityName = @"RootResource";

// API keys
NSString *const kRootResourceAuthenticationLevelAPIKey = @"authenticationlevel";
NSString *const kRootResourceMailboxesAPIKey = @"mailbox";

@implementation SHCRootResource

// Attributes
@dynamic authenticationLevel;
@dynamic createdAt;

// Relationships
@dynamic mailboxes;

#pragma mark - Public methods

+ (instancetype)rootResourceWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[SHCModelManager sharedManager] rootResourceEntity];
    SHCRootResource *rootResource = [[SHCRootResource alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

    NSNumber *authenticationLevel = attributes[kRootResourceAuthenticationLevelAPIKey];
    rootResource.authenticationLevel = [authenticationLevel isKindOfClass:[NSNumber class]] ? authenticationLevel : nil;

    rootResource.createdAt = [NSDate date];

    NSArray *mailboxesArray = attributes[kRootResourceMailboxesAPIKey];
    if ([mailboxesArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary *mailboxDict in mailboxesArray) {
            if ([mailboxDict isKindOfClass:[NSDictionary class]]) {
                SHCMailbox *mailbox = [SHCMailbox mailboxWithAttributes:mailboxDict inManagedObjectContext:managedObjectContext];
                mailbox.rootResource = rootResource;
                [rootResource addMailboxesObject:mailbox];
            }
        }
    }

    return rootResource;
}

+ (void)deleteAllRootResourcesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kRootResourceEntityName inManagedObjectContext:managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"Error executing fetch request: %@", [error localizedDescription]);
    }

    for (SHCRootResource *rootResource in results) {
        [managedObjectContext deleteObject:rootResource];
    }

    error = nil;
    if (![managedObjectContext save:&error]) {
        DDLogError(@"Error saving managed object context: %@", [error localizedDescription]);
    }
}

@end
