//
//  POSFolder+Methods.h
//  Digipost
//
//  Created by Håkon Bogen on 21.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSFolder.h"

@interface POSFolder (Methods)

+ (instancetype)pos_existingFolderWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
