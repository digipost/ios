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

#import "POSFolderTableViewCell.h"

NSString *const kFolderTableViewCellIdentifier = @"FolderCellIdentifier";

@implementation POSFolderTableViewCell

#pragma mark - UITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected
              animated:animated];

    [self showSelectedView:selected
                  animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted
                 animated:animated];

    [self showSelectedView:highlighted
                  animated:animated];
}

#pragma mark - Private methods

- (void)showSelectedView:(BOOL)showSelected animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
            self.selectedView.alpha = showSelected ? 1.0 : 0.0;
                         }];
    } else {
        self.selectedView.alpha = showSelected ? 1.0 : 0.0;
    }
}

@end
