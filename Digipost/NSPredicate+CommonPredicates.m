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
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"%K == %@", [NSString stringWithFormat:@"%@", NSStringFromSelector(@selector(name))], folderName];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ p1, p2 ]];
    return predicate;
}

+ (NSPredicate *)predicateForFoldersForDigipostAddress:(NSString *)digipostAddress
{
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"mailbox.digipostAddress == %@", digipostAddress];
    return p1;
}

+ (NSPredicate *)predicateWithDocumentsForMailBoxDigipostAddress:(NSString *)mailboxDigipostAddress inFolderWithName:(NSString *)folderName
{
    NSParameterAssert(folderName);
    NSParameterAssert(mailboxDigipostAddress);
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"folder.mailbox.digipostAddress == %@", mailboxDigipostAddress];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"%K == %@", [NSString stringWithFormat:@"%@.%@", @"folder", NSStringFromSelector(@selector(name))], folderName];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ p1, p2 ]];
    return predicate;
}

+ (NSPredicate *)predicateWithDocumentsForSelectedMailBox:(NSString *)digipostMailboxAddress inFolderWithName:(NSString *)folderName
{
    NSParameterAssert(folderName);
    NSParameterAssert(digipostMailboxAddress);
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"folder.mailbox.digipostAddress == %@", digipostMailboxAddress];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"%K == %@", [NSString stringWithFormat:@"%@.%@", @"folder", NSStringFromSelector(@selector(name))], folderName];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ p1, p2 ]];
    return predicate;
}

+ (NSPredicate *)predicateForFolderWithUri:(NSString *)uri
{
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"uri == %@", uri];
    return p1;
}
@end
