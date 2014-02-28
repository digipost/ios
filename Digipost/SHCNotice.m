//
//  SHCNotice.m
//  Digipost
//
//  Created by Håkon Bogen on 18.02.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
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
        if ([rel rangeOfString:kNoticeMoreInfoRelKey].location != NSNotFound){
            notice.moreInfoLink = attributes[@"uri"];
        }
        if ([rel rangeOfString:kNoticeDismissRelKey].location != NSNotFound){
            notice.dismissNoticeLink = attributes[@"uri"];
        }
    }
    return notice;
}
@end
