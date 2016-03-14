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

#import "POSNewFolderCollectionViewDataSource.h"
#import "POSNewFolderCollectionViewCell.h"
#import "UIColor+Convenience.h"

@import CoreData;

@interface POSNewFolderCollectionViewDataSource () <UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation POSNewFolderCollectionViewDataSource

- (id)initAsDataSourceForCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        collectionView.dataSource = self;
        [self setupDataItems];
    }
    return self;
}

- (void)setupDataItems
{
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[POSFolderIcon folderIconWithName:@"Folder"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Letter"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Paper"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Star"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Tags"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Heart"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Home"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Box"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Trophy"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Suitcase"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Money"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Camera"]];
    self.items = items;
}

- (POSFolderIcon *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.items objectAtIndex:indexPath.row];
}
#pragma mark - UICollectionVIew

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}

- (NSIndexPath *)indexPathForFolderIconWithName:(NSString *)name
{
    NSParameterAssert(name);

    __block NSUInteger index = -999;

    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        POSFolderIcon *folderIcon = obj;
        if ([folderIcon.name isEqualToString:name]){
            index = idx;
            *stop = YES;
        }
    }];
    if (index == -999) {
//        DDLogError(@"no index found for %@", name);
        NSAssert(index == -999, @"could not find correct index for icon");
    }
    return [NSIndexPath indexPathForRow:index
                              inSection:0];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    POSNewFolderCollectionViewCell *cell = (id)[collectionView dequeueReusableCellWithReuseIdentifier : @"cell" forIndexPath : indexPath];
    POSFolderIcon *folderIcon = [self.items objectAtIndex:indexPath.row];
    if ([[self.collectionView indexPathsForSelectedItems] containsObject:indexPath]) {

        cell.imageView.image = folderIcon.bigSelectedImage;
    } else {
        cell.imageView.image = folderIcon.bigImage;
    }
    return cell;
}

@end
