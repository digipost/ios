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

#import "UIBarButtonItem+DigipostBarButtonItems.h"

@implementation UIBarButtonItem (DigipostBarButtonItems)
+(UIBarButtonItem *)barButtonItemWithInfoImageForTarget:(id)target action:(SEL)action
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar-icon-info"]
                       landscapeImagePhone:[UIImage imageNamed:@"navbar-icon-info-iphone-landscape"]
                                     style:UIBarButtonItemStyleBordered
                                    target:target
                                    action:action];
    return barButtonItem;
}

+ (UIBarButtonItem*)barButtonItemWithActionImageForTarget: (id)target action: (SEL)action
{
   UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar-icon-action"]
                       landscapeImagePhone:[UIImage imageNamed:@"navbar-icon-action-iphone-landscape"]
                                     style:UIBarButtonItemStyleBordered
                                    target:target
                                    action:action];
    return barButtonItem;
}
@end
