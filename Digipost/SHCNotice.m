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

#import "SHCNotice.h"

NSString *const kNoticeMessageHeaderAPIKey = @"messageHeader";
NSString *const kNoticeMessageTextAPIKey = @"messageText";
NSString *const kNoticeDismissTextAPIKey = @"dismissText";
NSString *const kNoticeDLinkAPIKey = @"link";

NSString *const kNoticeDismissRelKey = @"dismiss_notice";
NSString *const kNoticeMoreInfoRelKey = @"more_info";

@implementation SHCNotice
+ (instancetype)noticeWithAttributes:(NSDictionary *)attributes
{
    SHCNotice *notice = [[SHCNotice alloc] init];
    //        "code": "FORSIKRING_AVTALEVILKAAR",
    //        "messageHeader": "Samtykke for forsikringsdokumenter",
    //        "messageText": "Du vil i fremtiden kunne motta forsikringsdokumenter fra selskaper du har avtale med i Digipost. For å bruke Digipost videre må du samtykke til dette.",
    //        "dismissText": "Jeg samtykker",
    //        "link": [
    //                {
    //                     "rel": "https://localhost:9090/post/relations/dismiss_notice",
    //                     "uri": "https://localhost:9090/post/api/private/accounts/1026/settings/acceptlatestterms",
    //                     "media-type": "application/vnd.digipost-v2+json"
    //                },
    //                {
    //                     "rel": "https://localhost:9090/post/relations/more_info",
    //                     "uri": "https://www.digipost.no/hjelp/forsikring",
    //                     "media-type": "text/html"
    //                }
    //                ]
    notice.messageHeader = attributes[kNoticeMessageHeaderAPIKey];
    notice.messageText = attributes[kNoticeMessageTextAPIKey];
    notice.dismissText = attributes[kNoticeDismissTextAPIKey];
    NSArray *linkArray = attributes[kNoticeDLinkAPIKey];
    for (NSDictionary *link in linkArray) {
        NSString *rel = attributes[@"rel"];
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
