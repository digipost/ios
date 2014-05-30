
//
//  POSNewFolderCollectionViewDataSource.m
//  Digipost
//
//  Created by Håkon Bogen on 27.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
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
    [items addObject:[POSFolderIcon folderIconWithName:@"Archive"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Camera"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Envelope"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"File"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Folder"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Heart"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Tags"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Home"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Star"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Suitcase"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"Trophy"]];
    [items addObject:[POSFolderIcon folderIconWithName:@"usd"]];

    //    [items addObject:@"Camera_128"];
    //    [items addObject:@"Envelope_128"];
    //    [items addObject:@"File_128"];
    //    [items addObject:@"Folder_128"];
    //    [items addObject:@"Heart_128"];
    //    [items addObject:@"Tags_128"];
    //    [items addObject:@"Home_128"];
    //    [items addObject:@"Star_128"];
    //    [items addObject:@"Suitcase_128"];
    //    [items addObject:@"Trophy_128"];
    //    [items addObject:@"USD_128"];

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
        DDLogError(@"no index found for %@", name);
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
