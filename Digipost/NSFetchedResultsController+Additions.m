//
//  NSFetchedResultsController+Additions.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "NSFetchedResultsController+Additions.h"
#import "SHCModelManager.h"

@implementation NSFetchedResultsController (Additions)
+ (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(NSEntityDescription *)entity sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate delegate:(id)delegate
{
    NSParameterAssert(entity);
    NSParameterAssert(sortDescriptors);
    NSParameterAssert(predicate);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.predicate = predicate;
    NSAssert(sortDescriptors != nil, @"No sort descriptors present");
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[SHCModelManager sharedManager].managedObjectContext
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    fetchedResultsController.delegate = delegate;
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Error performing fetchedResultsController fetch: %@", [error localizedDescription]);
    }

    return fetchedResultsController;
#warning potential bug prone
    //    [self.tableView reloadData];
    //    [self updateNavbar]
    // Because we don't know which subclass inherits from the base controller,
    // let's see if it responds to the updateFolders selector
    //    if ([self respondsToSelector:@selector(updateFolders)]) {
    //        [self performSelector:@selector(updateFolders)];
    //    }
}

@end
