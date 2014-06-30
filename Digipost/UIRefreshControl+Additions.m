//
//  UIRefreshControl+Additions.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "UIRefreshControl+Additions.h"
#import "POSModelManager.h"
#import "POSDocumentsViewController.h"
#import "POSReceiptFoldersTableViewController.h"

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
    if ([self isKindOfClass:[POSDocumentsViewController class]] ||
        [self isKindOfClass:[POSReceiptFoldersTableViewController class]]) {
        attributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.4
                                                                          alpha:1.0]};
    } else {
        attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }

    self.attributedTitle = [[NSAttributedString alloc] initWithString:@" "
                                                           attributes:attributes];
}
@end
