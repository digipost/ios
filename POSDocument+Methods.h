//
//  POSDocument+Methods.h
//  Digipost
//
//  Created by Håkon Bogen on 21.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSDocument.h"

@interface POSDocument (Methods)

+ (NSInteger)numberOfUnreadDocumentsForMailboxFolder:(POSFolder *)mailboxFolder inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSString *)authenticationLevelForMainAttachment;

@end
