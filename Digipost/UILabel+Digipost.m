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

#import "UILabel+Digipost.h"

@implementation UILabel (Digipost)

+ (UILabel *)tableViewMediumHeaderLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    [label setTextColor:RGB(64, 66, 69)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

+ (UILabel *)tableViewRegularHeaderLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17]];
    [label setTextColor:RGB(64, 66, 69)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}
+ (UILabel *)popoverViewDescriptionLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    [label setTextColor:RGB(153,153,153)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}
+ (UILabel *)popoverViewLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17]];
    [label setTextColor:RGB(51,51,51)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}
@end
