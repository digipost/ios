//
//  NSError+ExtraInfo.h
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (ExtraInfo)

@property (copy, nonatomic) NSString *errorTitle;
@property (copy, nonatomic) NSString *okButtonTitle;
@property (copy, nonatomic) void(^tapBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@end
