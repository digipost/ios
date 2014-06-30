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

#import "POSReceiptTableViewCell.h"

NSString *const kReceiptTableViewCellIdentifier = @"ReceiptCellIdentifier";

@implementation POSReceiptTableViewCell

#pragma mark - UITableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted
                 animated:animated];

    self.selectionStyle = self.isEditing && highlighted ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    self.tintColor = self.isEditing ? [UIColor colorWithRed:13.0 / 255.0
                                                      green:122.0 / 255.0
                                                       blue:1.0
                                                      alpha:1.0]
                                    : [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected
              animated:animated];

    self.selectionStyle = self.isEditing && selected ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    self.tintColor = self.isEditing ? [UIColor colorWithRed:64.0 / 255.0
                                                      green:66.0 / 255.0
                                                       blue:69.0 / 255.0
                                                      alpha:1.0]
                                    : [UIColor whiteColor];
}

@end
