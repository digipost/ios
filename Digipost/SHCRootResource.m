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
NSString *const kRootResourcePrimaryAccountAPIKey = @"primaryAccount";
NSString *const kRootResourceLinkAPIKey = @"link";
NSString *const kRootResourceLinkLogoutAPIKeySuffix = @"logout";
NSString *const kRootResourcePrimaryAccountLinkAPIKey = @"link";
NSString *const kRootResourcePrimaryAccountLinkCurrentBankAccountAPIKeySuffix = @"current_bank_account";
NSString *const kRootResourcePrimaryAccountLinkUploadDocumentAPISuffix = @"upload_document";
NSString *const kRootResourceNoticeAPIKey = @"notice";

@implementation SHCRootResource

// Attributes
@dynamic authenticationLevel;
@dynamic createdAt;
@dynamic currentBankAccount;
@dynamic currentBankAccountUri;
@dynamic firstName;
@dynamic fullName;
@dynamic lastName;
@dynamic logoutUri;
@dynamic middleName;
@dynamic numberOfCards;
@dynamic numberOfCardsReadyForVerification;
@dynamic numberOfReceiptsHiddenUntilVerification;
@dynamic unreadItemsInInbox;
@dynamic uploadDocumentUri;
// Relationships
@dynamic mailboxes;

// not stored in core data
@synthesize notice = _notice;

#pragma mark - Public methods

+ (instancetype)existingRootResourceInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] rootResourceEntity];
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}

+ (instancetype)rootResourceWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[SHCModelManager sharedManager] rootResourceEntity];
    SHCRootResource *rootResource = [[SHCRootResource alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

    NSNumber *authenticationLevel = attributes[kRootResourceAuthenticationLevelAPIKey];
    rootResource.authenticationLevel = [authenticationLevel isKindOfClass:[NSNumber class]] ? authenticationLevel : nil;

    rootResource.createdAt = [NSDate date];

    NSArray *links = attributes[kRootResourceLinkAPIKey];
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {
                    if ([rel hasSuffix:kRootResourceLinkLogoutAPIKeySuffix]) {
                        rootResource.logoutUri = uri;
                    }
                }
            }
        }
    }

    NSDictionary *primaryAccount = attributes[kRootResourcePrimaryAccountAPIKey];
    if ([primaryAccount isKindOfClass:[NSDictionary class]]) {
        NSString *firstName = primaryAccount[NSStringFromSelector(@selector(firstName))];
        rootResource.firstName = [firstName isKindOfClass:[NSString class]] ? firstName : nil;

        NSString *fullName = primaryAccount[NSStringFromSelector(@selector(fullName))];
        rootResource.fullName = [fullName isKindOfClass:[NSString class]] ? fullName : nil;

        NSString *lastName = primaryAccount[NSStringFromSelector(@selector(lastName))];
        rootResource.lastName = [lastName isKindOfClass:[NSString class]] ? lastName : nil;

        NSString *middleName = primaryAccount[NSStringFromSelector(@selector(middleName))];
        rootResource.middleName = [middleName isKindOfClass:[NSString class]] ? middleName : nil;

        NSNumber *unreadItemsInInbox = primaryAccount[NSStringFromSelector(@selector(unreadItemsInInbox))];
        rootResource.unreadItemsInInbox = [unreadItemsInInbox isKindOfClass:[NSNumber class]] ? unreadItemsInInbox : nil;

        NSArray *links = primaryAccount[kRootResourcePrimaryAccountLinkAPIKey];
        if ([links isKindOfClass:[NSArray class]]) {
            for (NSDictionary *link in links) {
                if ([link isKindOfClass:[NSDictionary class]]) {
                    NSString *rel = link[@"rel"];
                    NSString *uri = link[@"uri"];
                    if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {
                        if ([rel hasSuffix:kRootResourcePrimaryAccountLinkCurrentBankAccountAPIKeySuffix]) {
                            rootResource.currentBankAccountUri = uri;
                        } else if ([rel hasSuffix:kRootResourcePrimaryAccountLinkUploadDocumentAPISuffix]) {
                            rootResource.uploadDocumentUri = uri;
                        }
                    }
                }
            }
        }
    }

    NSArray *mailboxesArray = attributes[kRootResourceMailboxesAPIKey];
    if ([mailboxesArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary *mailboxDict in mailboxesArray) {
            if ([mailboxDict isKindOfClass:[NSDictionary class]]) {
                SHCMailbox *mailbox = [SHCMailbox mailboxWithAttributes:mailboxDict inManagedObjectContext:managedObjectContext];
                [rootResource addMailboxesObject:mailbox];
            }
        }
    }
    
    /**
     *   for future use when notices are delivered
     */
//    NSDictionary *noticeDictionary = attributes[kRootResourceNoticeAPIKey];
//    if (noticeDictionary != nil) {
//        rootResource.notice = [SHCNotice noticeWithAttributes:noticeDictionary];
//    }
    return rootResource;
}

+ (void)deleteAllRootResourcesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:kRootResourceEntityName inManagedObjectContext:managedObjectContext];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    for (SHCRootResource *rootResource in results) {
        [managedObjectContext deleteObject:rootResource];
    }
}
@end
