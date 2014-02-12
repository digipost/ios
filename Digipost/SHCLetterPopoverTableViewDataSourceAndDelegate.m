//
//  SHCLetterPopoverTableViewDataSource.m
//  Digipost
//
//  Created by Håkon Bogen on 11.02.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCLetterPopoverTableViewDataSourceAndDelegate.h"
#import "SHCLetterPopoverTableViewMobelObject.h"
#import "SHCLetterPopoverTableViewCell.h"

@implementation SHCLetterPopoverTableViewDataSourceAndDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self lineObjects]count];
}

- (SHCLetterPopoverTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCLetterPopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    SHCLetterPopoverTableViewMobelObject *popoverTableViewModelObject = self.lineObjects[indexPath.row];
    cell.titleLabel.text = popoverTableViewModelObject.title;
    cell.description.text = popoverTableViewModelObject.description;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCLetterPopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    SHCLetterPopoverTableViewMobelObject *popoverTableViewModelObject = self.lineObjects[indexPath.row];
    cell.titleLabel.text = popoverTableViewModelObject.title;
    cell.description.text = popoverTableViewModelObject.description;
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    return height + 5;
}
@end
