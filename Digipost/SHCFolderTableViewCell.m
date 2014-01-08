//
//  SHCFolderTableViewCell.m
//  Digipost
//
//  Created by Eivind Bohler on 12.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCFolderTableViewCell.h"

NSString *const kFolderTableViewCellIdentifier = @"FolderCellIdentifier";

@implementation SHCFolderTableViewCell

#pragma mark - UITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    [self showSelectedView:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    [self showSelectedView:highlighted animated:animated];
}

#pragma mark - Private methods

- (void)showSelectedView:(BOOL)showSelected animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectedView.alpha = showSelected ? 1.0 : 0.0;
        }];
    } else {
        self.selectedView.alpha = showSelected ? 1.0 : 0.0;
    }
}

@end
