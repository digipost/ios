//
//  SHCRootResource.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCRootResource.h"
#import "SHCMailbox.h"

// Core Data model entity names
NSString *const kRootResourceEntityName = @"RootResource";

// API keys
NSString *const kRootResourceAuthenticationLevelAPIKey = @"authenticationlevel";
NSString *const kRootResourceMailboxesAPIKey = @"mailbox";

@implementation SHCRootResource

// Attributes
@dynamic authenticationLevel;

// Relationships
@dynamic mailboxes;

#pragma mark - Public methods

+ (instancetype)rootResourceWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    SHCRootResource *rootResource = nil;

    NSEntityDescription *entity = [NSEntityDescription entityForName:kRootResourceEntityName inManagedObjectContext:managedObjectContext];
    rootResource = [[SHCRootResource alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

    NSNumber *authenticationLevel = attributes[kRootResourceAuthenticationLevelAPIKey];
    rootResource.authenticationLevel = [authenticationLevel isKindOfClass:[NSNumber class]] ? authenticationLevel : nil;

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

@end
