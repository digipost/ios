//
//  SHCLetterPopoverTableViewMobelObject.m
//  Digipost
//
//  Created by Håkon Bogen on 11.02.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCLetterPopoverTableViewMobelObject.h"

@implementation SHCLetterPopoverTableViewMobelObject
+ (SHCLetterPopoverTableViewMobelObject *)initWithTitle:(NSString *)title description:(NSString *)description
{
    SHCLetterPopoverTableViewMobelObject *ptvmo = [[SHCLetterPopoverTableViewMobelObject alloc] init];
    ptvmo.title = title;
    ptvmo.description = description;
    return ptvmo;
}
@end
