//
//  SHCDocumentTableViewCell.m
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCDocumentTableViewCell.h"

NSString *const kDocumentTableViewCellIdentifier = @"DocumentCellIdentifier";

@implementation SHCDocumentTableViewCell

#pragma mark - UIView

#pragma mark - UITableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    self.selectionStyle = self.isEditing && highlighted ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    self.tintColor = self.isEditing ? [UIColor colorWithRed:13.0/255.0 green:122.0/255.0 blue:1.0 alpha:1.0] : [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.selectionStyle = self.isEditing && selected ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    self.tintColor = self.isEditing ? [UIColor colorWithRed:13.0/255.0 green:122.0/255.0 blue:1.0 alpha:1.0] : [UIColor whiteColor];
}

@end
