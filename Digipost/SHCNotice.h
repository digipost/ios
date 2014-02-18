//
//  SHCNotice.h
//  Digipost
//
//  Created by Håkon Bogen on 18.02.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHCNotice : NSObject
@property (nonatomic,strong) NSString *messageHeader;
@property (nonatomic,strong) NSString *messageText;
@property (nonatomic,strong) NSString *dismissText;
@property (nonatomic,strong) NSString *moreInfoLink;
@property (nonatomic,strong) NSString *dismissNoticeLink;

+ (instancetype)noticeWithAttributes:(NSDictionary *)attributes;
@end
