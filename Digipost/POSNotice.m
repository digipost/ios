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

#import "POSNotice.h"

NSString *const kNoticeMessageHeaderAPIKey = @"messageHeader";
NSString *const kNoticeMessageTextAPIKey = @"messageText";
NSString *const kNoticeDismissTextAPIKey = @"dismissText";
NSString *const kNoticeDLinkAPIKey = @"link";

NSString *const kNoticeDismissRelKey = @"dismiss_notice";
NSString *const kNoticeMoreInfoRelKey = @"more_info";

@implementation POSNotice
+ (instancetype)noticeWithAttributes:(NSDictionary *)attributes
{
    POSNotice *notice = [[POSNotice alloc] init];
    notice.messageHeader = attributes[kNoticeMessageHeaderAPIKey];
    notice.messageText = attributes[kNoticeMessageTextAPIKey];
    notice.dismissText = attributes[kNoticeDismissTextAPIKey];
    NSArray *linkArray = attributes[kNoticeDLinkAPIKey];
    for (NSDictionary *link in linkArray) {
        NSString *rel = link[@"rel"];
        if ([rel rangeOfString:kNoticeMoreInfoRelKey].location != NSNotFound) {
            notice.moreInfoLink = attributes[@"uri"];
        }
        if ([rel rangeOfString:kNoticeDismissRelKey].location != NSNotFound) {
            notice.dismissNoticeLink = attributes[@"uri"];
        }
    }
    return notice;
}
@end
