//
//  SHCLetterPopoverTableViewMobelObject.h
//  Digipost
//
//  Created by Håkon Bogen on 11.02.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHCLetterPopoverTableViewMobelObject : NSObject

@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *description;

+ (SHCLetterPopoverTableViewMobelObject*)initWithTitle:(NSString*)title description:(NSString*)description;
@end
