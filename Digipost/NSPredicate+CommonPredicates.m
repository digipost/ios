//
//  NSPredicate+CommonPredicates.m
//  Digipost
//
//  Created by Håkon Bogen on 21.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "NSPredicate+CommonPredicates.h"

@implementation NSPredicate (CommonPredicates)

#pragma mark - Predicates
+ (NSPredicate *)predicateWithFoldersInMailbox:(NSString *)mailboxDigipostAddress
{
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"mailbox.digipostAddress == %@", mailboxDigipostAddress];
    return p1;
}

+ (NSPredicate *)folderWithName:(NSString *)folderName mailboxDigipostAddressPredicate:(NSString *)mailboxDigipostAddress
{
    NSParameterAssert(folderName);
    NSParameterAssert(mailboxDigipostAddress);
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"mailbox.digipostAddress == %@", mailboxDigipostAddress];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"%K == %@", [NSString stringWithFormat:@"%@", NSStringFromSelector(@selector(name))],folderName];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[p1, p2]];
    return predicate;
}
+ (NSPredicate *)predicateWithDocumentsForMailBoxDigipostAddress: (NSString*)mailboxDigipostAddress inFolderWithName:(NSString *)folderName
{
    NSParameterAssert(folderName);
    NSParameterAssert(mailboxDigipostAddress);
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"folder.mailbox.digipostAddress == %@", mailboxDigipostAddress];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"%K == %@", [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(folder)), NSStringFromSelector(@selector(name))],folderName];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[p1, p2]];
    return predicate;
}

+ (NSPredicate *)predicateWithDocumentsForSelectedMailBox: (NSString *)digipostMailboxAddress inFolderWithName:(NSString *)folderName
{
    NSParameterAssert(folderName);
    NSParameterAssert(digipostMailboxAddress);
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"folder.mailbox.digipostAddress == %@", digipostMailboxAddress];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"%K == %@", [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(folder)), NSStringFromSelector(@selector(name))],folderName];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[p1, p2]];
    return predicate;
}


@end
