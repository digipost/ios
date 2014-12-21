//
//  POSDocument+Methods.m
//  Digipost
//
//  Created by Håkon Bogen on 21.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
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
