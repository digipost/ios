//
//  POSFolder+Methods.m
//  Digipost
//
//  Created by Håkon Bogen on 21.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSFolder+Methods.h"
#import "POSModelManager.h"
#import "NSPredicate+CommonPredicates.h"

@implementation POSFolder (Methods)
+ (instancetype)pos_existingFolderWithUri:(NSString *)uri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[POSModelManager sharedManager] folderEntity];
    fetchRequest.predicate = [NSPredicate predicateForFolderWithUri:uri];

    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    if (error) {
        [[POSModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}
@end
