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

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class POSRootResource;

@interface SHCBaseTableViewController : UITableViewController

@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSEntityDescription *baseEntity;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSPredicate *predicate;
@property (strong, nonatomic) POSRootResource *rootResource;

// Override these methods in subclass
- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *) userDidInititateRequest;
- (void)updateNavbar;

- (void)updateFetchedResultsController;
- (void)programmaticallyEndRefresh;


@end
