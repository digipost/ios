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

#import "UIRefreshControl+Additions.h"
#import "POSModelManager.h"
#import "POSDocumentsViewController.h"

@implementation UIRefreshControl (Additions)
- (void)updateRefreshControlTextRefreshing:(BOOL)refreshing
{
    NSString *text = nil;
    if (refreshing) {
        text = NSLocalizedString(@"GENERIC_UPDATING_TITLE", @"Updating...");
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;

        NSString *lastUpdatedText = NSLocalizedString(@"GENERIC_LAST_UPDATED_TITLE", @"Last updated");

        NSString *lastUpdatedDate = [dateFormatter stringFromDate:[[POSModelManager sharedManager] rootResourceCreatedAt]];
        lastUpdatedDate = lastUpdatedDate ?: NSLocalizedString(@"GENERIC_UPDATED_NEVER_TITLE", @"never");

        text = [NSString stringWithFormat:@"%@: %@", lastUpdatedText, lastUpdatedDate];
    }

    NSDictionary *attributes = [self.attributedTitle attributesAtIndex:0
                                                        effectiveRange:NULL];
    self.attributedTitle = [[NSAttributedString alloc] initWithString:text
                                                           attributes:attributes];
}

- (void)initializeRefreshControlText
{
    NSDictionary *attributes = nil;
    if ([self isKindOfClass:[POSDocumentsViewController class]]) {
        attributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.4
                                                                          alpha:1.0]};
    } else {
        attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }

    self.attributedTitle = [[NSAttributedString alloc] initWithString:@" "
                                                           attributes:attributes];
}
@end
