//
//  UIViewController+ValidateOpening.m
//  Digipost
//
//  Created by Eivind Bohler on 13.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "UIViewController+ValidateOpening.h"
#import "SHCAttachment.h"
#import "NSError+ExtraInfo.h"

@implementation UIViewController (ValidateOpening)

- (void)validateOpeningAttachment:(SHCAttachment *)attachment success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    if (![attachment.authenticationLevel isEqualToString:kAttachmentOpeningValidAuthenticationLevel]) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:kAttachmentOpeningValidAuthenticationLevel
                                                 code:SHCAttachmentOpeningValidationErrorCodeWrongAuthenticationLevel
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"ATTACHMENT_VALIDATION_ERROR_WRONG_AUTHENTICATION_LEVEL_MESSAGE", @"Wrong authentication level validation error message")}];
            error.errorTitle = NSLocalizedString(@"ATTACHMENT_VALIDATION_ERROR_WRONG_AUTHENTICATION_LEVEL_TITLE", @"Insufficient authentication level");
            failure(error);
        }
    } else if (!attachment.uri) {
        // If the attachment doesn't have a uri, it probably means the letter requires
        // an opening receipt or something else that Digipost knows the app can't handle.

        if (failure) {
            NSError *error = [NSError errorWithDomain:kAttachmentOpeningValidAuthenticationLevel
                                                 code:SHCAttachmentOpeningValidationErrorCodeNoAttachmentUri
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"ATTACHMENT_VALIDATION_ERROR_GENERIC_MESSAGE", @"Generic validation error message")}];
            error.errorTitle = NSLocalizedString(@"ATTACHMENT_VALIDATION_ERROR_GENERIC_TITLE", @"Unable to open letter");
            failure(error);
        }
    } else {
        if (success) {
            success();
        }
    }
}

@end
