//
//  NSFetchedResultsController+Additions.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "NSFetchedResultsController+Additions.h"
#import "POSModelManager.h"

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
                                                                                               managedObjectContext:[POSModelManager sharedManager].managedObjectContext
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    fetchedResultsController.delegate = delegate;
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
    }

    return fetchedResultsController;
}

@end
