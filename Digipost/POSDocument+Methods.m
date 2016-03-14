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

#import "POSDocument+Methods.h"
#import "POSModelManager.h"
#import "POSAttachment.h"
#import "NSPredicate+CommonPredicates.h"

@implementation POSDocument (Methods)
+ (NSInteger)numberOfUnreadDocumentsForMailboxFolder:(POSFolder *)mailboxFolder inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] documentEntity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@ ", NSStringFromSelector(@selector(folder)), mailboxFolder];

    NSError *error;
    NSArray *documents = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    __block NSInteger unread = 0;
    [documents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        POSDocument *document = obj;
        [document.attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            POSAttachment *attachment = obj;
            if ([attachment.mainDocument boolValue]){
                if ([attachment.read boolValue] == NO){
                    unread++;
                }
                *stop = YES;
            }
        }];
    }];
    return unread;
}

- (NSString *)authenticationLevelForMainAttachment
{
    __block NSString *authenticationLevel = nil;
    [self.attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        POSAttachment *attachment = (id) obj;
        if (attachment.mainDocument.boolValue) {
            authenticationLevel = attachment.authenticationLevel;
        }
    }];
    return authenticationLevel;
}
@end
