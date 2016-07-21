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
    [self setCancelButtonTitle: NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")];
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
