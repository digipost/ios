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

#import <objc/runtime.h>
#import "UIViewController+NeedsReload.h"

static void *kNeedsReloadContext = &kNeedsReloadContext;

@implementation UIViewController (NeedsReload)

- (BOOL)needsReload
{
    NSNumber *needsReloadNumber = objc_getAssociatedObject(self, kNeedsReloadContext);

    BOOL needsReload = [needsReloadNumber boolValue];

    return needsReload;
}

- (void)setNeedsReload:(BOOL)needsReload
{
    objc_setAssociatedObject(self, kNeedsReloadContext, [NSNumber numberWithBool:needsReload], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
