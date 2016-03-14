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
