//
//  SHCReceiptTableViewCell.m
//  Digipost
//
//  Created by Eivind Bohler on 20.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCReceiptTableViewCell.h"

NSString *const kReceiptTableViewCellIdentifier = @"ReceiptCellIdentifier";

@implementation SHCReceiptTableViewCell

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
