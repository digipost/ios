//
//  AHKActionSheet+Convenience.m
//  Digipost
//
//  Created by Håkon Bogen on 03.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "AHKActionSheet+Convenience.h"
#import "UIColor+Convenience.h"

@implementation AHKActionSheet (Convenience)
- (void)setupStyle
{

    [self setBlurTintColor:[UIColor pos_colorWithR:64
                                                 G:66
                                                 B:69
                                             alpha:0.80]];
    self.automaticallyTintButtonImages = @YES;
    [self setButtonHeight:50];
    [self setBlurRadius:4.5f];

    self.separatorColor = [UIColor pos_colorWithR:255
                                                G:255
                                                B:255
                                            alpha:0.30f];

    [self setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self setButtonTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self setCancelButtonTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

+ (AHKActionSheet *)setupActionButtonsForLetterController:(POSLetterViewController *)letterViewController
{
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:NSLocalizedString(@"actions action sheet title", @"")];
    [actionSheet setupStyle];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"actions action sheet move document", @"title for move document in the multiple actions action sheet")
                              image:[UIImage imageNamed:@"Move"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet) {
                                [letterViewController showMoveDocumentActionSheet];
                            }];

    [actionSheet addButtonWithTitle:NSLocalizedString(@"actions action sheet delete document", @"")
                              image:[UIImage imageNamed:@"Delete"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet) {
                                [letterViewController showDeleteDocumentActionSheet];
                            }];

    [actionSheet addButtonWithTitle:NSLocalizedString(@"actions action sheet rename document", @"")
                              image:[UIImage imageNamed:@"New name"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet) {
                                [letterViewController showRenameAlertView];
                            }];

    [actionSheet addButtonWithTitle:NSLocalizedString(@"actions action sheet open in app", @"")
                              image:[UIImage imageNamed:@"Open_in"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet) {
                                [letterViewController showOpenInControllerModally];
                            }];
    return actionSheet;
}

@end
