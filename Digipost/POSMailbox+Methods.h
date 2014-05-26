//
//  POSMailbox+Methods.h
//  Digipost
//
//  Created by Håkon Bogen on 26.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSMailbox.h"

@interface POSMailbox (Methods)

+ (instancetype)mailboxWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)existingMailboxWithDigipostAddress:(NSString *)digipostAddress inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)deleteAllMailboxesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSInteger)numberOfMailboxesStoredInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (POSMailbox *)mailboxInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end
