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

#import "POSLetterPopoverTableViewDataSourceAndDelegate.h"
#import "POSLetterPopoverTableViewMobelObject.h"
#import "POSLetterPopoverTableViewCell.h"

@implementation POSLetterPopoverTableViewDataSourceAndDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self lineObjects] count];
}

- (POSLetterPopoverTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POSLetterPopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                                          forIndexPath:indexPath];
    POSLetterPopoverTableViewMobelObject *popoverTableViewModelObject = self.lineObjects[indexPath.row];
    cell.titleLabel.text = popoverTableViewModelObject.title;
    cell.description.text = popoverTableViewModelObject.description;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POSLetterPopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    POSLetterPopoverTableViewMobelObject *popoverTableViewModelObject = self.lineObjects[indexPath.row];
    cell.titleLabel.text = popoverTableViewModelObject.title;
    cell.description.text = popoverTableViewModelObject.description;
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    return height + 5;
}
@end
