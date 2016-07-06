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

#import "UIViewController+ValidateOpening.h"
#import "POSAttachment.h"
#import "NSError+ExtraInfo.h"
#import "Digipost-Swift.h"

@implementation UIViewController (ValidateOpening)

- (void)validateOpeningAttachment:(POSAttachment *)attachment success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    if (attachment.openingReceiptUri) {
        if (success) {
            success();
        }
    } else if (!attachment.uri) {
        success();
        return;
    }else {
        if (success) {
            success();
        }
    }
}

@end
